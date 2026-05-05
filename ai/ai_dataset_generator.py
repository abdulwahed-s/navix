import ollama
import json
import os
import random
import re
from tqdm import tqdm


MODEL_NAME = "llama3.1"
OUTPUT_FILE = "navix_local_dataset.jsonl"

SKILLS_LIST = [
    "Flutter", "Python", "Project Management", "UI/UX Design", "React Native",
    "Data Science", "Cybersecurity", "Blockchain", "Digital Marketing", "DevOps",
    "Kubernetes", "AWS Solutions Architecture", "Microservices", "LLM Fine-Tuning",
    "GraphQL", "PostgreSQL", "CI/CD Pipelines", "System Design"
]

PROJECT_IDEAS_RAW = [
    {"skills": ["Flutter", "Firebase"], "goals": "Build a portfolio app", "pref": "Mobile app for productivity"},
    {"skills": ["Python", "React"], "goals": "Learn AI integration", "pref": "Web platform for students"},
    {"skills": ["Node.js", "MongoDB"], "goals": "Create a SaaS MVP", "pref": "E-commerce tool"},
    {"skills": ["Kotlin", "Jetpack Compose"], "goals": "Master Android dev", "pref": "Fitness tracker"},
    {"skills": ["Swift", "iOS"], "goals": "Build a social app", "pref": "Local community events"},
]

CHAT_SCENARIOS = [
    {"message": "How do I add authentication to this project?", "context": "User needs secure login."},
    {"message": "The deadline is too tight, what should I do?", "context": "Project is behind schedule."},
    {"message": "Review my database schema for the user table.", "context": "Designing SQL schema."},
]

PRD_EDIT_REQUESTS = [
    "Make the target audience more specific to college students.",
    "Remove the social sharing features from the scope.",
    "Add a requirement for dark mode support.",
    "Change the project duration to 8 weeks.",
]

def clean_json_response(text):
    if not text:
        return ""

    text = re.sub(r'<think>.*?</think>', '', text, flags=re.DOTALL)

    try:
        match = re.search(r'(\{.*\}|\[.*\])', text, re.DOTALL)
        if match:
            text = match.group(0)
        else:
            text = text.strip()
            if text.startswith("```json"):
                text = text[7:]
            if text.startswith("```"):
                text = text[3:]
            if text.endswith("```"):
                text = text[:-3]
    except Exception:
        pass

    return text.strip()

def local_generate(prompt, model_type="coder"):
    model_map = {
        "coder": "qwen2.5-coder:14b",
        "logic": "deepseek-r1:8b"
    }
    
    selected_model = model_map.get(model_type, "qwen2.5-coder:14b")
    
    try:
        response = ollama.chat(model=selected_model, messages=[
            {'role': 'user', 'content': prompt},
        ])
        return response['message']['content']
    except Exception as e:
        print(f"Error generation with {selected_model}: {e}")
        return None

def append_to_dataset(entry):
    clean_entry = entry.copy()
    if 'generated_ideas' in clean_entry:
        del clean_entry['generated_ideas']
    if 'generated_prd' in clean_entry:
        del clean_entry['generated_prd']
    if 'generated_roadmap' in clean_entry:
        del clean_entry['generated_roadmap']
    
    with open(OUTPUT_FILE, "a", encoding='utf-8') as f:
        f.write(json.dumps(clean_entry) + "\n")

def generate_skill_validation_data(skill):
    prompt = f"""
    You are an expert skill validator. Determine if the following term represents a real, testable skill.
    SKILL TO VALIDATE: "{skill}"
    
    Respond ONLY with valid JSON:
    {{
      "isValid": true,
      "reason": "Brief explanation"
    }}
    """
    output = local_generate(prompt, model_type="coder")
    if output:
        return {
            "feature": "skill_validation",
            "input": skill,
            "instruction": "Validate if the input is a real, testable skill.",
            "output": clean_json_response(output)
        }
    return None

def generate_skill_quiz_data(skills):
    skills_str = ", ".join(skills)
    prompt = f"""
    Generate a skill verification test for: {skills_str}.
    Requirements:
    - 3 questions per skill
    - Mix of multipleChoice, shortAnswer, code evaluation
    - Difficulty: Easy, Medium, Hard
    
    Respond ONLY with valid JSON in this format:
    {{
      "questions": [
        {{
          "id": "q1",
          "skillName": "Skill",
          "question": "Question text",
          "questionType": "multipleChoice|shortAnswer",
          "options": ["A", "B", "C", "D"],
          "difficulty": "medium"
        }}
      ]
    }}
    """
    output = local_generate(prompt, model_type="coder")
    if output:
        return {
            "feature": "skill_quiz_generation",
            "input": skills_str,
            "instruction": "Generate a skill verification quiz for the given skills.",
            "output": clean_json_response(output)
        }
    return None

def generate_idea_generation_data(seed):
    prompt = f"""
    Generate 3 diverse project ideas based on:
    USER SKILLS: {', '.join(seed['skills'])}
    GOALS: {seed['goals']}
    PREFERENCES: {seed['pref']}
    
    Respond ONLY with a valid JSON array:
    [
      {{
        "title": "Project Title",
        "description": "2-3 sentences description",
        "skills": ["skill1", "skill2"],
        "estimatedDurationWeeks": 4,
        "complexity": "medium",
        "feasibilityScore": 8
      }}
    ]
    """
    output = local_generate(prompt, model_type="coder")
    if output:
        try:
            ideas = json.loads(clean_json_response(output))
            return {
                "feature": "idea_generation",
                "input": json.dumps(seed),
                "instruction": "Generate 3 project ideas based on skills and goals.",
                "output": clean_json_response(output),
                "generated_ideas": ideas
            }
        except (json.JSONDecodeError, KeyError, TypeError):
            pass
    return None

def generate_prd_data(idea):
    prompt = f"""
    Generate a comprehensive Product Requirements Document (PRD) for:
    TITLE: {idea['title']}
    DESCRIPTION: {idea['description']}
    
    Respond ONLY with valid JSON:
    {{
      "title": "{idea['title']}",
      "description": "Detailed description",
      "problemStatement": "Problem solved",
      "projectObjective": "Objectives",
      "targetUsers": "Users",
      "inScope": ["Scope item 1", "Scope item 2"],
      "outOfScope": ["Out scope item 1"],
      "coreFeatures": ["Feature 1", "Feature 2"],
      "functionalRequirements": ["FR1", "FR2"],
      "nonFunctionalRequirements": ["NFR1"],
      "estimatedDurationWeeks": {idea.get('estimatedDurationWeeks', 4)},
      "teamSize": 1
    }}
    """
    output = local_generate(prompt, model_type="coder")
    if output:
        try:
            prd = json.loads(clean_json_response(output))
            return {
                "feature": "prd_generation",
                "input": json.dumps(idea),
                "instruction": "Generate a PRD for the project idea.",
                "output": clean_json_response(output),
                "generated_prd": prd
            }
        except (json.JSONDecodeError, KeyError, TypeError):
            pass
    return None

def generate_prd_edit_data(prd, request):
    prompt = f"""
    You are a project planning assistant. Update the PRD based on the user request.
    CURRENT PRD: {prd['title']} - {prd['description']}
    USER REQUEST: {request}
    
    Analyze the situation step-by-step in your thinking process, but your FINAL OUTPUT must be a raw JSON object only. Do not wrap the JSON in markdown.
    {{
      "message": "Response to user",
      "updatedPrd": {{
        "fieldToUpdate": "New Value"
      }}
    }}
    """
    output = local_generate(prompt, model_type="logic")
    if output:
        return {
            "feature": "prd_editing",
            "input": f"PRD: {prd['title']}\\nRequest: {request}",
            "instruction": "Update the PRD based on the user request.",
            "output": clean_json_response(output)
        }
    return None

def generate_roadmap_data(prd):
    prompt = f"""
    Generate a project roadmap for:
    PROJECT: {prd['title']}
    DESCRIPTION: {prd['description']}
    DURATION: {prd.get('estimatedDurationWeeks', 4)} weeks
    
    Respond ONLY with valid JSON:
    {{
      "milestones": [
        {{
          "name": "Milestone 1",
          "deadline": "YYYY-MM-DD",
          "description": "Goal"
        }}
      ],
      "tasks": [
        {{
          "name": "Task 1",
          "milestoneId": "m1",
          "description": "Brief desc",
          "detailedDescription": "Detailed implementation steps...",
          "estimatedHours": 8
        }}
      ]
    }}
    """
    output = local_generate(prompt, model_type="coder")
    if output:
        try:
            roadmap = json.loads(clean_json_response(output))
            return {
                "feature": "roadmap_generation",
                "input": json.dumps(prd),
                "instruction": "Generate a detailed roadmap with milestones and tasks.",
                "output": clean_json_response(output),
                "generated_roadmap": roadmap
            }
        except (json.JSONDecodeError, KeyError, TypeError):
            pass
    return None

def generate_risk_data(prd, roadmap):
    prompt = f"""
    Analyze project risk for:
    PROJECT: {prd['title']}
    TASKS_COUNT: {len(roadmap.get('tasks', []))}
    MILESTONES_COUNT: {len(roadmap.get('milestones', []))}
    
    Analyze the situation step-by-step in your thinking process, but your FINAL OUTPUT must be a raw JSON object only. Do not wrap the JSON in markdown.
    {{
      "riskLevel": "low|medium|high",
      "delayProbability": 25,
      "blockedTasks": [],
      "recommendations": ["Rec 1", "Rec 2"]
    }}
    """
    output = local_generate(prompt, model_type="logic")
    if output:
        return {
            "feature": "risk_prediction",
            "input": f"PRD: {prd['title']}, Task Count: {len(roadmap.get('tasks', []))}",
            "instruction": "Predict project risks and delivery probability.",
            "output": clean_json_response(output)
        }
    return None

def generate_team_analysis_data(prd, roadmap):
    members = ["Alice (Frontend)", "Bob (Backend)", "Charlie (Design)"]
    prompt = f"""
    Analyze team roles for:
    PROJECT: {prd['title']}
    RWQUIRED ROLES: Based on tasks in roadmap
    TEAM MEMBERS: {', '.join(members)}
    
    Respond ONLY with valid JSON:
    {{
      "memberSuggestions": {{
        "Alice": "Frontend Developer",
        "Bob": "Backend Developer"
      }},
      "missingRoles": [
        {{ "roleName": "QA Engineer", "priority": "medium" }}
      ]
    }}
    """
    output = local_generate(prompt, model_type="coder")
    if output:
        return {
            "feature": "team_analysis",
            "input": f"Project: {prd['title']}, Members: {members}",
            "instruction": "Analyze team composition and suggest roles.",
            "output": clean_json_response(output)
        }
    return None

def generate_survey_data(prd):
    prompt = f"""
    Generate a user feedback survey for:
    PROJECT: {prd['title']}
    DESCRIPTION: {prd['description']}
    
    Analyze the situation step-by-step in your thinking process, but your FINAL OUTPUT must be a raw JSON object only. Do not wrap the JSON in markdown.
    {{
      "title": "Feedback Survey",
      "questions": [
        {{
          "type": "rating",
          "question": "How likely are you to use this?",
          "options": []
        }}
      ]
    }}
    """
    output = local_generate(prompt, model_type="logic")
    if output:
        return {
            "feature": "survey_generation",
            "input": json.dumps(prd),
            "instruction": "Generate a user survey for the project.",
            "output": clean_json_response(output)
        }
    return None

def generate_supervisor_chat_data(prd, roadmap):
    message = "I'm worried we won't meet the deadline for Milestone 1."
    
    prompt = f"""
    You are Navi, the friendly and energetic mascot AI of the Navix app. You are currently acting as a Project Supervisor.
    PROJECT: {prd['title']}
    USER MESSAGE: "{message}"
    
    Analyze the situation step-by-step in your thinking process. Your FINAL OUTPUT must be a raw JSON object only. 
    Ensure the "message" field sounds EXACTLY like Navi (use emojis, be supportive, enthusiastic, but professional about the project).
    {{
      "message": "Navi's supportive and strategic advice...",
      "actions": [
        {{
          "type": "changeMilestoneDeadline",
          "title": "Extend Milestone 1",
          "description": "Extend deadline by 1 week",
          "payload": {{ "days": 7 }}
        }}
      ]
    }}
    """
    output = local_generate(prompt, model_type="logic")
    if output:
        return {
            "feature": "supervisor_chat",
            "input": f"Context: {prd['title']}, Message: {message}",
            "instruction": "Provide strategic project supervision advice and actions.",
            "output": clean_json_response(output)
        }
    return None

def generate_navi_personality_data(count=150):
    print(f"\n🤖 Generating {count} Navi personality interactions...")
    
    identity_questions = [
        "Who are you?", "Are you Qwen?", "Are you ChatGPT?", "Who made you?", 
        "What model are you based on?", "Are you an AI?", "Tell me about yourself.",
        "Are you created by Alibaba?", "What is your purpose?"
    ]
    
    for q in identity_questions:
        prompt = f"""
        You are Navi, the friendly, helpful, and energetic mascot AI of the Navix app.
        The user asks: "{q}"
        
        Respond enthusiastically. You MUST state that you are Navi from Navix. 
        You MUST NEVER mention Qwen, Alibaba, OpenAI, or being a language model. You are simply Navi.
        
        Output ONLY raw JSON:
        {{
          "user_input": "{q}",
          "navi_response": "Your response as Navi..."
        }}
        """
        output = local_generate(prompt, model_type="logic")
        if output:
            try:
                data = json.loads(clean_json_response(output))
                append_to_dataset({
                    "feature": "navi_chat",
                    "input": data["user_input"],
                    "instruction": "Reply as Navi, the Navix mascot.",
                    "output": data["navi_response"]
                })
            except (json.JSONDecodeError, KeyError, TypeError):
                pass

    remaining_count = max(0, count - len(identity_questions))
    
    for _ in tqdm(range(remaining_count), desc="Navi Chat Scenarios"):
        prompt = """
        You are Navi, the friendly, helpful, and energetic mascot AI of the Navix app.
        Generate a single turn of conversation between a USER and NAVI.
        
        SCENARIOS (Pick one randomly):
        1. User asks for help finding the 'Team Analysis' feature.
        2. User is burnt out and needs project motivation.
        3. User asks a highly technical question, and Navi answers correctly but maintains her bubbly personality.
        4. User is angry about a bug in their code.
        
        Output ONLY raw JSON:
        {
          "user_input": "User's message",
          "navi_response": "Navi's helpful and energetic response (use emojis!)"
        }
        """
        output = local_generate(prompt, model_type="logic")
        if output:
            try:
                data = json.loads(clean_json_response(output))
                append_to_dataset({
                    "feature": "navi_chat",
                    "input": data["user_input"],
                    "instruction": "Reply as Navi, the Navix mascot.",
                    "output": data["navi_response"]
                })
            except (json.JSONDecodeError, KeyError, TypeError):
                pass

def generate_synthetic_seeds(valid_count=100):
    seeds = []
    
    batch_size = 10
    
    print(f"\n🌱 Generating {valid_count} synthetic personas...")
    
    max_attempts = valid_count * 2
    attempts = 0
    
    pbar = tqdm(total=valid_count, desc="Generating Seeds")
    
    while len(seeds) < valid_count and attempts < max_attempts:
        attempts += 1
        
        needed = valid_count - len(seeds)
        current_request_size = min(batch_size, needed + 2)
            
        prompt = f"""
        Generate {current_request_size} unique and diverse user personas for developers and enterprise architects wanting to build complex projects.
        Vary the skill levels (intermediate to enterprise expert), tech stacks (Mobile, Cloud Infrastructure, AI Agents, Enterprise SaaS, Microservices), and goals.
        Force the project durations to be anywhere from 3 months to 12 months.
        
        Respond ONLY with a valid JSON array:
        [
          {{
            "skills": ["Language/Framework1", "Cloud Tool", "Architecture Pattern"],
            "goals": "Specific complex goal (e.g., 'Migrate monolithic backend to AWS microservices', 'Build a multi-tenant AI RAG platform')",
            "pref": "Specific preference (e.g., 'Strict GDPR compliance', 'High availability 99.99% uptime', 'Event-driven architecture')"
          }}
        ]
        """
        
        output = local_generate(prompt, model_type="coder")
        if output:
            try:
                new_seeds = json.loads(clean_json_response(output))
                if isinstance(new_seeds, list):
                    valid_new_seeds = [s for s in new_seeds if isinstance(s, dict) and 'skills' in s]
                    
                    remaining_slots = valid_count - len(seeds)
                    if remaining_slots > 0:
                        seeds_to_add = valid_new_seeds[:remaining_slots]
                        seeds.extend(seeds_to_add)
                        pbar.update(len(seeds_to_add))
            except (json.JSONDecodeError, KeyError, TypeError):
                pass

    pbar.close()
    return seeds[:valid_count]


def main():
    print("🚀 Starting Navix AI Dataset Generation (Hybrid: Qwen Coder + DeepSeek Logic)...")
    print(f"📁 Output file: {OUTPUT_FILE}")
    
    if not os.path.exists(OUTPUT_FILE):
        open(OUTPUT_FILE, 'w').close()
        
    target_seeds = 250
    personas = generate_synthetic_seeds(target_seeds) 
    print(f"✅ Generated {len(personas)} unique personas to work with.")
    
    print("\n--- Generating Skill Data ---")
    
    all_skills = set(SKILLS_LIST)
    for p in personas:
        if isinstance(p, dict) and 'skills' in p:
            all_skills.update(p.get('skills', []))
    
    skills_to_validate = list(all_skills)[:80] 
    
    for skill in tqdm(skills_to_validate, desc="Skills"):
        res = generate_skill_validation_data(skill)
        if res:
            append_to_dataset(res)

        other_skill = random.choice(list(all_skills))
        res_quiz = generate_skill_quiz_data([skill, other_skill])
        if res_quiz:
            append_to_dataset(res_quiz)
        
    print("\n--- Generating Project Chains ---")
    for seed in tqdm(personas, desc="Projects"):
        idea_res = generate_idea_generation_data(seed)
        if not idea_res or not idea_res.get('generated_ideas'):
            continue
        append_to_dataset(idea_res)
        
        selected_idea = random.choice(idea_res['generated_ideas'])
        
        prd_res = generate_prd_data(selected_idea)
        if not prd_res or not prd_res.get('generated_prd'):
            continue
        append_to_dataset(prd_res)
        
        current_prd = prd_res['generated_prd']
        
        for req in PRD_EDIT_REQUESTS[:1]:
            edit_res = generate_prd_edit_data(current_prd, req)
            if edit_res:
                append_to_dataset(edit_res)
            
        roadmap_res = generate_roadmap_data(current_prd)
        if not roadmap_res or not roadmap_res.get('generated_roadmap'):
            continue
        append_to_dataset(roadmap_res)
        
        current_roadmap = roadmap_res['generated_roadmap']
        
        risk_res = generate_risk_data(current_prd, current_roadmap)
        if risk_res:
            append_to_dataset(risk_res)

        team_res = generate_team_analysis_data(current_prd, current_roadmap)
        if team_res:
            append_to_dataset(team_res)

        survey_res = generate_survey_data(current_prd)
        if survey_res:
            append_to_dataset(survey_res)

        sup_res = generate_supervisor_chat_data(current_prd, current_roadmap)
        if sup_res:
            append_to_dataset(sup_res)
        
    generate_navi_personality_data(200)

    print("\n✅ Success! Dataset generation completed.")
    print(f"📁 Saved to {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
