

import * as functions from "firebase-functions/v2";
import * as admin from "firebase-admin";
import {
  onDocumentWritten,
  onDocumentCreated,
} from "firebase-functions/v2/firestore";

admin.initializeApp();


export const updatePostVoteScore = onDocumentWritten(
  "posts/{postId}/votes/{userId}",
  async (event) => {
    const postId = event.params.postId;
    const postRef = admin.firestore().collection("posts").doc(postId);

    try {

      const votesSnapshot = await postRef.collection("votes").get();
      let upvotes = 0;
      let downvotes = 0;

      votesSnapshot.forEach((doc) => {
        const voteType = doc.data().voteType;
        if (voteType === "up") {
          upvotes++;
        } else if (voteType === "down") {
          downvotes++;
        }
      });


      const postDoc = await postRef.get();
      if (!postDoc.exists) {
        functions.logger.warn(`Post ${postId} not found`);
        return null;
      }

      const postData = postDoc.data();
      if (!postData) {
        functions.logger.warn(`Post ${postId} has no data`);
        return null;
      }

      const createdAt = postData.createdAt.toDate();


      const now = new Date();
      const hoursSincePost =
        (now.getTime() - createdAt.getTime()) / (1000 * 60 * 60);


      const voteScore =
        (upvotes - downvotes) / Math.pow(hoursSincePost + 2, 1.5);


      await postRef.update({
        upvotes,
        downvotes,
        voteScore,
      });

      functions.logger.info(
        `Updated post ${postId}: ` +
        `upvotes=${upvotes}, downvotes=${downvotes}, ` +
        `voteScore=${voteScore.toFixed(2)}`
      );

      return null;
    } catch (error) {
      functions.logger.error(`Error updating post vote score: ${error}`);
      return null;
    }
  }
);


export const updateCommentVoteScore = onDocumentWritten(
  "posts/{postId}/comments/{commentId}/votes/{userId}",
  async (event) => {
    const { postId, commentId } = event.params;
    const commentRef = admin.firestore()
      .collection("posts").doc(postId)
      .collection("comments").doc(commentId);

    try {

      const votesSnapshot = await commentRef.collection("votes").get();
      let upvotes = 0;
      let downvotes = 0;

      votesSnapshot.forEach((doc) => {
        const voteType = doc.data().voteType;
        if (voteType === "up") {
          upvotes++;
        } else if (voteType === "down") {
          downvotes++;
        }
      });


      const commentDoc = await commentRef.get();
      if (!commentDoc.exists) {
        functions.logger.warn(`Comment ${commentId} not found`);
        return null;
      }

      const commentData = commentDoc.data();
      if (!commentData) {
        functions.logger.warn(`Comment ${commentId} has no data`);
        return null;
      }

      const createdAt = commentData.createdAt.toDate();


      const now = new Date();
      const hoursSinceComment =
        (now.getTime() - createdAt.getTime()) / (1000 * 60 * 60);


      const voteScore =
        (upvotes - downvotes) / Math.pow(hoursSinceComment + 2, 1.5);


      await commentRef.update({
        upvotes,
        downvotes,
        voteScore,
      });

      functions.logger.info(
        `Updated comment ${commentId}: ` +
        `upvotes=${upvotes}, downvotes=${downvotes}, ` +
        `voteScore=${voteScore.toFixed(2)}`
      );

      return null;
    } catch (error) {
      functions.logger.error(
        `Error updating comment vote score: ${error}`
      );
      return null;
    }
  }
);


export const updateCommentCount = onDocumentWritten(
  "posts/{postId}/comments/{commentId}",
  async (event) => {
    const postId = event.params.postId;
    const postRef = admin.firestore().collection("posts").doc(postId);

    try {

      const commentsSnapshot = await postRef.collection("comments").get();
      const commentCount = commentsSnapshot.size;


      await postRef.update({ commentCount });

      functions.logger.info(
        `Updated post ${postId} comment count: ${commentCount}`
      );

      return null;
    } catch (error) {
      functions.logger.error(`Error updating comment count: ${error}`);
      return null;
    }
  }
);


export const notifyOnComment = onDocumentCreated(
  "posts/{postId}/comments/{commentId}",
  async (event) => {
    const { postId, commentId } = event.params;
    const commentData = event.data?.data();

    if (!commentData) {
      functions.logger.warn(`Comment ${commentId} has no data`);
      return null;
    }

    const db = admin.firestore();
    const commenterId = commentData.authorId;
    const parentCommentId = commentData.parentCommentId;

    try {

      const commenterProfileDoc = await db
        .collection("users")
        .doc(commenterId)
        .collection("profile")
        .doc("main")
        .get();

      const commenterName = commenterProfileDoc.exists ?
        commenterProfileDoc.data()?.name || "Someone" :
        "Someone";


      const postDoc = await db.collection("posts").doc(postId).get();
      if (!postDoc.exists) {
        functions.logger.warn(`Post ${postId} not found`);
        return null;
      }

      const postData = postDoc.data();
      if (!postData) {
        functions.logger.warn(`Post ${postId} has no data`);
        return null;
      }

      const postAuthorId = postData.authorId;
      const postTitle = postData.title || "your post";


      const truncatedTitle = postTitle.length > 30 ?
        postTitle.substring(0, 30) + "..." :
        postTitle;

      const now = admin.firestore.FieldValue.serverTimestamp();

      if (parentCommentId) {
        const parentCommentDoc = await db
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(parentCommentId)
          .get();

        if (parentCommentDoc.exists) {
          const parentCommentData = parentCommentDoc.data();
          const parentAuthorId = parentCommentData?.authorId;


          if (parentAuthorId && parentAuthorId !== commenterId) {
            await db.collection("notifications").add({
              userId: parentAuthorId,
              type: "commentReply",
              title: "New Reply",
              body: `${commenterName} replied to your comment`,
              read: false,
              createdAt: now,
              relatedId: postId,
              data: {
                postId,
                commentId,
                parentCommentId,
                replierId: commenterId,
                replierName: commenterName,
              },
            });

            functions.logger.info(
              `Created reply notification for user ${parentAuthorId}`
            );
          }
        }
      }


      if (postAuthorId !== commenterId) {
        await db.collection("notifications").add({
          userId: postAuthorId,
          type: "newComment",
          title: "New Comment",
          body: `${commenterName} commented on "${truncatedTitle}"`,
          read: false,
          createdAt: now,
          relatedId: postId,
          data: {
            postId,
            commentId,
            commenterId,
            commenterName,
          },
        });

        functions.logger.info(
          `Created comment notification for post author ${postAuthorId}`
        );
      }

      return null;
    } catch (error) {
      functions.logger.error(`Error creating comment notification: ${error}`);
      return null;
    }
  }
);

