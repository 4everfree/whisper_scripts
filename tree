import os

def generate_checkbox_tree(path, level=0):
    output = ""
    items = sorted([i for i in os.listdir(path) if not i.startswith('.') and i != 'generate_tasks.py'])
    
    for item in items:
        full_path = os.path.join(path, item)
        indent = "    " * level 
        
        if os.path.isdir(full_path):
            output += f"{indent}- [ ] **{item}/**\n"
            output += generate_checkbox_tree(full_path, level + 1)
        else:
            output += f"{indent}- [ ] {item}\n"
            
    return output

output_file = "todo_structure.md"
with open(output_file, "w", encoding="utf-8") as f:
    f.write("# File Checklist\n\n")
    f.write(generate_checkbox_tree("."))

print(f"Done! Checkbox structure saved to {output_file}")
