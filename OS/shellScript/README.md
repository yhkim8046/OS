## **🔷 Bash Script Collection**
🚀 This repository contains two simple Bash scripts that handle **argument validation and file checking**.

---

## 📌 **Scripts Overview**
| Script Name      | Description |
|-----------------|-------------|
| `file_check.sh` | Checks if exactly one argument is passed and verifies if the file exists. |
| `arg_check.sh`  | Ensures exactly **two** arguments are provided, otherwise exits with an error. |

---

## 📌 **1️⃣ `file_check.sh` - File Existence Checker**
### **🔹 Description**
This script checks:
✔ If exactly **one argument** is provided.  
✔ If the given argument is a **valid file**.  

### **🔹 Usage**
```sh
./file_check.sh <filename>
```

### **🔹 Example Execution**
✅ **Valid File**
```sh
$ ./file_check.sh myfile.txt
# (Script continues execution)
```
❌ **File Not Found**
```sh
$ ./file_check.sh nonexistent.txt
Error: The file 'nonexistent.txt' does not exist.
```
❌ **Missing Argument**
```sh
$ ./file_check.sh
Error: You must provide exactly one argument.
Usage: ./file_check.sh filename
```

---

## 📌 **2️⃣ `arg_check.sh` - Argument Count Validator**
### **🔹 Description**
This script ensures:
✔ Exactly **two arguments** are provided.  
✔ If not, it prints an error message and exits with **exit code 255**.  

### **🔹 Usage**
```sh
./arg_check.sh <param1> <param2>
```

### **🔹 Example Execution**
✅ **Valid Execution**
```sh
$ ./arg_check.sh apple banana
# (Script continues execution)
```
❌ **Missing Arguments**
```sh
$ ./arg_check.sh apple
Usage: ./arg_check.sh parm1 parm2
Please enter 2 arguments exactly
```
❌ **Extra Arguments**
```sh
$ ./arg_check.sh apple banana cherry
Usage: ./arg_check.sh parm1 parm2
Please enter 2 arguments exactly
```

---

## 📌 **Installation & Execution**
### **1️⃣ Clone the Repository**
```sh
git clone https://github.com/YOUR_USERNAME/bash-scripts.git
cd bash-scripts
```
### **2️⃣ Grant Execute Permissions**
```sh
chmod +x file_check.sh arg_check.sh
```
### **3️⃣ Run the Scripts**
```sh
./file_check.sh example.txt
./arg_check.sh param1 param2
```

---

## 📌 **License**
This project is licensed under the **MIT License**.