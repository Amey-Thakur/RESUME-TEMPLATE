#!/usr/bin/env python3
import json
import os
import shutil

# Resolve directories relative to the script location
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, "../resume/configuration"))
SECTIONS_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, "../resume/sections"))
SOURCE_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, "../resume/source"))

json_path = os.path.join(CONFIG_DIR, "resume_data.json")
template_path = os.path.join(CONFIG_DIR, "resume_data.template.json")

# Check if target data JSON exists; fallback to template if missing
if not os.path.exists(json_path):
    print("Local resume_data.json not found. Copying template...")
    shutil.copyfile(template_path, json_path)

print(f"Reading data from {json_path}...")
with open(json_path, 'r', encoding='utf-8') as f:
    raw_data = json.load(f)

def escape_latex(val):
    if val is None:
        return ""
    text = str(val)
    
    # 1. Escape LaTeX reserved character symbols
    text = text.replace('&', '\\&')
    text = text.replace('%', '\\%')
    text = text.replace('_', '\\_')
    text = text.replace('#', '\\#')
    text = text.replace('$', '\\$')
    
    # 2. Normalize vertical pipe separator character to standard LaTeX vertical spacer
    text = text.replace(' \\$|\\$ ', ' $|$ ')
    text = text.replace(' | ', ' $|$ ')
    text = text.replace('|', ' $|$ ')
    
    return text

def escape_object(obj):
    if obj is None:
        return None
    if isinstance(obj, str):
        return escape_latex(obj)
    if isinstance(obj, list):
        return [escape_object(item) for item in obj]
    if isinstance(obj, dict):
        return {k: escape_object(v) for k, v in obj.items()}
    return obj

print("Escaping JSON strings for LaTeX compatibility...")
data = escape_object(raw_data)

# Create folders if missing
os.makedirs(SECTIONS_DIR, exist_ok=True)
os.makedirs(SOURCE_DIR, exist_ok=True)

# 1. Generate resume/configuration/metadata.tex
print("Generating: resume/configuration/metadata.tex")
metadata = f"""%-------------------------
% Personal Details and Links Configuration
%-------------------------
\\newcommand{{\\myName}}{{{data['personal_info']['name']}}}
\\newcommand{{\\myPhone}}{{{data['personal_info']['phone']}}}
\\newcommand{{\\myEmail}}{{{data['personal_info']['email']}}}
\\newcommand{{\\myLinkedIn}}{{{data['personal_info']['linkedin']}}}
\\newcommand{{\\myLinkedInUrl}}{{{data['personal_info']['linkedin_url']}}}
\\newcommand{{\\myGitHub}}{{{data['personal_info']['github']}}}
\\newcommand{{\\myGitHubUrl}}{{{data['personal_info']['github_url']}}}
\\newcommand{{\\myLocation}}{{{data['personal_info']['location']}}}
"""
with open(os.path.join(CONFIG_DIR, "metadata.tex"), "w", encoding='utf-8') as f:
    f.write(metadata)

# 2. Generate resume/sections/summary.tex
print("Generating: resume/sections/summary.tex")
summary = f"""%-------------------------
% Professional Summary Section
%-------------------------
\\section{{Summary}}
\\small{{{data['resume']['summary']}}}
"""
with open(os.path.join(SECTIONS_DIR, "summary.tex"), "w", encoding='utf-8') as f:
    f.write(summary)

# 3. Generate resume/sections/education.tex
print("Generating: resume/sections/education.tex")
edu_items = []
for edu in data['resume']['education']:
    edu_items.append("  \\resumeSubheading")
    edu_items.append(f"    {{{edu['institution']}}}{{{edu['location']}}}")
    edu_items.append(f"    {{{edu['degree']}}}{{{edu['date']}}}")
education = f"""%-------------------------
% Education Section
%-------------------------
\\section{{Education}}
\\resumeSubHeadingListStart
{chr(10).join(edu_items)}
\\resumeSubHeadingListEnd
"""
with open(os.path.join(SECTIONS_DIR, "education.tex"), "w", encoding='utf-8') as f:
    f.write(education)

# 4. Generate resume/sections/experience.tex
print("Generating: resume/sections/experience.tex")
exp_items = []
for job in data['resume']['experience']:
    exp_items.append("  \\resumeSubheading")
    exp_items.append(f"    {{{job['role']}}}{{{job['date']}}}")
    exp_items.append(f"    {{{job['company']}}}{{{job['location']}}}")
    exp_items.append("    \\resumeItemListStart")
    for bullet in job['bullets']:
        exp_items.append(f"      \\resumeItem{{{bullet}}}")
    exp_items.append("    \\resumeItemListEnd\n")
experience = f"""%-------------------------
% Professional Experience Section
%-------------------------
\\section{{Professional Experience}}
\\resumeSubHeadingListStart\n
{chr(10).join(exp_items)}
\\resumeSubHeadingListEnd
"""
with open(os.path.join(SECTIONS_DIR, "experience.tex"), "w", encoding='utf-8') as f:
    f.write(experience)

# 5. Generate resume/sections/skills.tex
print("Generating: resume/sections/skills.tex")
skills_items = []
for skill_cat in data['resume']['skills']:
    skills_items.append(f"  \\small \\item \\textbf{{{skill_cat['category']}}}{{: {skill_cat['items']}}}")
skills = f"""%-------------------------
% Technical Skills Section
%-------------------------
\\section{{Technical Skills}}
\\begin{{itemize}}[leftmargin=0.15in, label={{}}, itemsep=3pt]
{chr(10).join(skills_items)}
\\end{{itemize}}
"""
with open(os.path.join(SECTIONS_DIR, "skills.tex"), "w", encoding='utf-8') as f:
    f.write(skills)

# 6. Generate resume/sections/certifications.tex
print("Generating: resume/sections/certifications.tex")
cert_items = []
for cert in data['resume']['certifications']:
    cert_items.append(f"  \\small \\item \\textbf{{{cert['category']}}}{{: {cert['items']}}}")
certifications = f"""%-------------------------
% Certifications & Distinctions Section
%-------------------------
\\section{{Certifications \& Distinctions}}
\\begin{{itemize}}[leftmargin=0.15in, label={{}}, itemsep=3pt]
{chr(10).join(cert_items)}
\\end{{itemize}}
"""
with open(os.path.join(SECTIONS_DIR, "certifications.tex"), "w", encoding='utf-8') as f:
    f.write(certifications)

# 7. Generate resume/source/cover_letter.tex
print("Generating: resume/source/cover_letter.tex")
paragraphs = []
for p in data['cover_letter']['paragraphs']:
    paragraphs.append(f"\\noindent {p}\n\n\\vspace{{1em}}")
cover_letter = f"""%-------------------------
% Main Cover Letter Entry Point
%-------------------------
\\documentclass[letterpaper,11pt]{{article}}

\\usepackage{{../templates/cover_letter}}
\\input{{../configuration/metadata}}

\\begin{{document}}

\\makeHeader

\\vspace{{2em}}

\\today

\\vspace{{1em}}
\\noindent\\textbf{{{data['cover_letter']['recipient']['name']}}} \\newline
{data['cover_letter']['recipient']['company']} \\newline
{data['cover_letter']['recipient']['address']}

\\vspace{{2em}}

\\noindent\\textbf{{{data['cover_letter']['subject']}}}

\\vspace{{1em}}

\\noindent Dear {data['cover_letter']['recipient']['name']},

\\vspace{{1em}}

{chr(10).join(paragraphs)}

\\vspace{{1em}}

\\noindent Sincerely,

\\vspace{{1.5em}}

\\noindent \\textbf{{\\myName}}

\\end{{document}}
"""
with open(os.path.join(SOURCE_DIR, "cover_letter.tex"), "w", encoding='utf-8') as f:
    f.write(cover_letter)

print("All LaTeX source files updated from JSON data.")
