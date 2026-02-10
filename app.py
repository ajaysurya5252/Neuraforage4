import sqlite3
import joblib
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# ==================== LOAD MODEL ====================
try:
    model = joblib.load("career_model.pkl")
    print("✅ ML Model loaded: career_model.pkl")
except:
    print("❌ Model not found! Run train_full_model.py first")
    exit()

# ==================== CAREER MAP ====================
CAREER_MAP = {
    0: {
        "name": "AI / Data Science / Software Engineering",
        "salary": "8-15 LPA",
        "growth": "Very High",
        "required_skills": ["Python", "Machine Learning", "SQL", "AI"],
        "roadmap": {
            1: ["Python Basics", "Math Fundamentals"],
            2: ["Data Structures", "SQL", "Web Development"],
            3: ["Machine Learning", "Deep Learning", "Projects"],
            4: ["Advanced AI", "Internships", "Portfolio"]
        }
    },
    1: {
        "name": "Core Engineering (Mechanical/Civil/Electrical)",
        "salary": "4-8 LPA",
        "growth": "Moderate",
        "required_skills": ["AutoCAD", "SolidWorks", "Domain Knowledge"],
        "roadmap": {
            1: ["Engineering Drawing", "CAD Basics"],
            2: ["AutoCAD 2D/3D", "Material Science"],
            3: ["SolidWorks", "FEA Analysis", "Projects"],
            4: ["Industry Training", "Certifications"]
        }
    },
    2: {
        "name": "Design / UI/UX / Creative",
        "salary": "5-10 LPA",
        "growth": "High",
        "required_skills": ["Figma", "Adobe XD", "Design Thinking"],
        "roadmap": {
            1: ["Design Fundamentals", "Color Theory"],
            2: ["Figma", "Adobe XD", "Prototyping"],
            3: ["UI/UX Projects", "Portfolio Building"],
            4: ["Advanced Design", "Freelancing"]
        }
    },
    3: {
        "name": "Government Jobs (UPSC/SSC/Banking)",
        "salary": "5-8 LPA",
        "growth": "Stable",
        "required_skills": ["General Knowledge", "Aptitude", "Current Affairs"],
        "roadmap": {
            1: ["NCERT Books", "Basic Aptitude"],
            2: ["Current Affairs", "Mock Tests"],
            3: ["Previous Papers", "Coaching"],
            4: ["Full-time Preparation", "Interviews"]
        }
    },
    4: {
        "name": "Higher Studies (MS/MBA/PhD)",
        "salary": "Variable",
        "growth": "High (Long-term)",
        "required_skills": ["Research", "GATE/GRE/GMAT", "Academic Excellence"],
        "roadmap": {
            1: ["Focus on CGPA", "Fundamentals"],
            2: ["Research Projects", "Publications"],
            3: ["GATE/GRE Prep", "SOP Writing"],
            4: ["Applications", "Interviews"]
        }
    },
    5: {
        "name": "Startup / Entrepreneurship",
        "salary": "Variable",
        "growth": "Very High (Risk)",
        "required_skills": ["Business", "Leadership", "Product Development"],
        "roadmap": {
            1: ["Idea Validation", "Market Research"],
            2: ["MVP Development", "Networking"],
            3: ["Funding", "Team Building"],
            4: ["Scaling", "Growth Hacking"]
        }
    }
}

DEPT_MAP = {
    "Computer Science": 0,
    "Information Tech": 0,
    "Mechanical": 1,
    "Civil": 1,
    "Electrical": 1,
    "Other": 2
}

# ==================== DATABASE ====================
class StudentDB:
    def __init__(self):
        self.conn = sqlite3.connect("students_full.db", check_same_thread=False)
        self.create_tables()

    def create_tables(self):
        c = self.conn.cursor()
        c.execute("""
        CREATE TABLE IF NOT EXISTS students(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            department TEXT,
            year INTEGER,
            cgpa REAL,
            skills TEXT,
            interests TEXT,
            personality TEXT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
        """)
        c.execute("""
        CREATE TABLE IF NOT EXISTS predictions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER,
            career TEXT,
            confidence REAL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
        """)
        c.execute("""
        CREATE TABLE IF NOT EXISTS feedback(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER,
            career TEXT,
            helpful INTEGER,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
        """)
        self.conn.commit()

    def add_student(self, d):
        c = self.conn.cursor()
        c.execute("""
        INSERT INTO students(name, department, year, cgpa, skills, interests, personality)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """, (d["name"], d["department"], d["year"], d["cgpa"], 
              d["skills"], d["interests"], d.get("personality", "")))
        self.conn.commit()
        return c.lastrowid

    def add_prediction(self, sid, career, conf):
        c = self.conn.cursor()
        c.execute("INSERT INTO predictions(student_id, career, confidence) VALUES (?, ?, ?)", 
                  (sid, career, conf))
        self.conn.commit()

    def add_feedback(self, sid, career, helpful):
        c = self.conn.cursor()
        c.execute("INSERT INTO feedback(student_id, career, helpful) VALUES (?, ?, ?)",
                  (sid, career, helpful))
        self.conn.commit()

db = StudentDB()

# ==================== FEATURE EXTRACTION ====================
def extract_features(data):
    dept_code = DEPT_MAP.get(data["department"], 2)
    year = int(data["year"])
    cgpa = float(data["cgpa"])
    
    skills_str = data.get("skills", "").lower()
    interests_str = data.get("interests", "").lower()
    
    python = 1 if "python" in skills_str else 0
    java = 1 if "java" in skills_str else 0
    sql = 1 if "sql" in skills_str else 0
    ml = 1 if "machine learning" in skills_str or "ml" in skills_str else 0
    ai = 1 if "ai" in interests_str else 0
    coding = 1 if "coding" in interests_str else 0
    design = 1 if "design" in interests_str or "figma" in skills_str else 0
    
    # NEW: Personality features
    logic_thinking = int(data.get("logic_thinking", 0))
    teamwork = int(data.get("teamwork", 0))
    risk_taking = int(data.get("risk_taking", 0))
    
    features = np.array([[dept_code, year, cgpa, python, java, sql, ml, ai, 
                          coding, design, logic_thinking, teamwork, risk_taking]])
    
    return features

# ==================== GAP ANALYSIS ====================
def get_skill_gaps(user_skills, required_skills):
    user_set = set(s.strip().lower() for s in user_skills.split(",") if s.strip())
    required_set = set(s.lower() for s in required_skills)
    
    missing = [s for s in required_skills if s.lower() not in user_set]
    matched = [s for s in required_skills if s.lower() in user_set]
    
    return {
        "missing": missing,
        "matched": matched,
        "match_percentage": int((len(matched) / len(required_skills)) * 100) if required_skills else 0
    }

# ==================== API ROUTES ====================
@app.route("/")
def home():
    return jsonify({
        "status": "✅ AI Career Navigator - FULL VERSION",
        "features": [
            "Personalized Matching (with Personality)",
            "Career Suitability Scores",
            "Dynamic Semester Roadmaps",
            "Automatic Gap Analysis",
            "Self-Updating (Feedback)",
            "Multi-Path Options (6 careers)"
        ]
    })

@app.route("/api/recommend", methods=["POST"])
def recommend():
    try:
        data = request.json
        
        student_id = db.add_student(data)
        features = extract_features(data)
        
        prediction = int(model.predict(features)[0])
        probabilities = model.predict_proba(features)[0]
        
        career_info = CAREER_MAP[prediction]
        db.add_prediction(student_id, career_info["name"], float(probabilities.max()))
        
        recommendations = []
        for idx in np.argsort(probabilities)[::-1][:3]:  # Top 3
            career = CAREER_MAP[idx]
            prob = probabilities[idx]
            score = int(prob * 100)
            
            # Gap analysis
            gaps = get_skill_gaps(data.get("skills", ""), career["required_skills"])
            
            # Roadmap for current year
            current_year = int(data.get("year", 1))
            semester_plan = career["roadmap"].get(current_year, [])
            
            recommendations.append({
                "career": career["name"],
                "score": score,
                "suitability_text": f"You are {score}% suitable for {career['name']}",
                "salary": career["salary"],
                "growth": career["growth"],
                "required_skills": career["required_skills"],
                "gap_analysis": gaps,
                "semester_roadmap": {
                    "year": current_year,
                    "skills": semester_plan
                }
            })
        
        return jsonify({
            "success": True,
            "student": {
                "id": student_id,
                "name": data["name"]
            },
            "recommendations": recommendations
        })
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/feedback", methods=["POST"])
def submit_feedback():
    try:
        data = request.json
        db.add_feedback(data["student_id"], data["career"], data["helpful"])
        return jsonify({"success": True})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

if __name__ == "__main__":
    print("\n" + "="*60)
    print("🚀 AI CAREER NAVIGATOR - FULL FEATURES ACTIVATED")
    print("="*60)
    app.run(debug=True, port=5001, host='0.0.0.0')