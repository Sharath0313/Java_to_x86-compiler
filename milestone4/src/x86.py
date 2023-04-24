import sys

if len(sys.argv) != 2 and len(sys.argv) != 3:
    sys.exit("The syntax to run x86.py file is: python3 x86.py input3ac_filename {output_filname}\nwhere {} means optional")

input_3ac = open(sys.argv[1],"r")

inst_3ac = input_3ac.readlines()
x86 = []
if len(sys.argv) == 2:
    outfile = open("x86.s","w")
else :
    outfile = open(sys.argv[2],"w")

inst_3ac = [x[:-1] for x in inst_3ac]

i = 0

x86.append(".LC0:\n")
x86.append("\t.string \"%d\\n\"\n")

while i<len(inst_3ac):

    pop_curr_param = 1
    push_curr_param = 1
    param = {1:"%rdi", 2:"%rsi", 3:"%rdx", 4:"%rcx", 5:"%r8", 6:"%r9"}
    x86.append("\t.text\n")
    if "main" in inst_3ac[i]:
        x86.append("\t.globl main\n")
        x86.append("\t.type main, @function"+"\n")
        x86.append("main:\n")
    else:
        x86.append("\t.globl "+inst_3ac[i][:-1]+"\n")
        x86.append("\t.type "+inst_3ac[i][:-1]+", @function"+"\n")
        x86.append(inst_3ac[i]+"\n")
    offset = {}
    var_no = 0
    reg = {"%rbx":0, "%r12":0, "%r13":0, "%r14":0, "%r15":0, "%rax":0, "%rcx":0, "%rdx":0, "%r8":0, "%r9":0, "%r10":0, "%r11":0}
    var_reg = {}
    cond = {}
    classfields = {}
    classoff = 0
    i += 1
    stack_space_line = -1 

    while i<len(inst_3ac) and (not(len(inst_3ac[i].split())==1 and inst_3ac[i][0] != '.' and inst_3ac[i][len(inst_3ac[i])-1]==':')):
        words = inst_3ac[i].split()
        if "push stackbase" in inst_3ac[i]:
            x86.append("\tpushq %rbp\n")
        elif "stackbase = stacktop" in inst_3ac[i]:
            x86.append("\tmovq %rsp, %rbp\n")
            x86.append("\n")
            stack_space_line = len(x86)-1
        elif "pop stackbase" in inst_3ac[i]:
            i += 1
            continue
        elif "EndFunction" in inst_3ac[i]:
            i += 1
            continue
        elif "EndProgram" in inst_3ac[i]:
            i += 1
            continue
        elif "return" in words[0]:
            if len(words) == 1:
                x86.append("\tleave\n")
                x86.append("\tret\n")
            else :
                if words[1][0] == '_':
                    x86.append("\tmovq "+var_reg[words[1]]+", %rax\n")
                    x86.append("\tleave\n")
                    x86.append("\tret\n")
                    reg[var_reg[words[1]]] = 0
                elif words[1] in offset:
                    x86.append("\tmovq "+offset[words[1]]+"(%rbp), %rax\n")
                    x86.append("\tleave\n")
                    x86.append("\tret\n")
                elif ((ord(words[1][0])-ord('0'))<10 and (ord(words[1][0])-ord('0'))>-1)  or  (words[1][0] == '-'):
                    x86.append("\tmovq $"+words[1]+", %rax\n")
                    x86.append("\tleave\n")
                    x86.append("\tret\n")
                elif words[1][0] == "*" and (words[1][1:] in classfields):
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq "+offset["this"]+"(%rbp),"+" "+x+"\n")
                            break
                    x86.append("\tmovq "+classfields[words[1][1:]]+"("+x+"), %rax\n")
                    x86.append("\tleave\n")
                    x86.append("\tret\n")
                elif words[1][0] == '*' and words[1][1] == '_':
                    x86.append("\tmovq ("+var_reg[words[1][1:]]+"), %rax"+"\n")
                    x86.append("\tleave\n")
                    x86.append("\tret\n")
                    reg[var_reg[words[1][1:]]] = 0
        elif "call System.out.println" in inst_3ac[i]:
            x86.append("\tmovq %rdi, %rsi\n")
            x86.append("\tleaq .LC0(%rip), %rdi\n")
            x86.append("\tmovl $0, %eax\n")
            x86.append("\tcall printf@PLT\n")
            push_curr_param = 1
        elif len(words) == 1:
            if "L" in words[0]:
                x86.append(words[0]+"\n")
        elif len(words) == 2:
            if "param" in words[0]:
                push_param = []
                while "param" in inst_3ac[i].split()[0]:
                    par_words = inst_3ac[i].split()
                    if push_curr_param <= 6:
                        if par_words[1][0] == "_":
                            push_param.append("\tmovq "+var_reg[par_words[1]]+", "+param[push_curr_param]+"\n")
                            reg[var_reg[par_words[1]]] = 0
                        elif par_words[1] in offset:
                            push_param.append("\tmovq "+offset[par_words[1]]+"(%rbp), "+param[push_curr_param]+"\n")
                        elif ((ord(par_words[1][0])-ord('0'))<10 and (ord(par_words[1][0])-ord('0'))>-1) or (par_words[1][0] == '-'):
                            push_param.append("\tmovq $"+par_words[1]+", "+param[push_curr_param]+"\n")
                        elif par_words[1][0] == "*" and (par_words[1][1:] in classfields):
                            for x in reg:
                                if reg[x]==0:
                                    push_param.append("\tmovq "+classfields[par_words[1][1:]]+"("+x+"), "+param[push_curr_param]+"\n")
                                    push_param.append("\tmovq "+offset["this"]+"(%rbp),"+" "+x+"\n")
                                    break
                        elif par_words[1][0] == '*' and par_words[1][1] == '_':
                            push_param.append("\tmovq ("+var_reg[par_words[1][1:]]+"), "+param[push_curr_param]+"\n")
                            reg[var_reg[par_words[1][1:]]] = 0
                        push_curr_param += 1
                    else :
                        if par_words[1][0] == "_":
                            push_param.append("\tpushq "+var_reg[par_words[1]]+"\n")
                        elif par_words[1] in offset:
                            push_param.append("\tpushq "+offset[par_words[1]]+"(%rbp)\n")
                        elif ((ord(par_words[1][0])-ord('0'))<10 and (ord(par_words[1][0])-ord('0'))>-1) or (par_words[1][0] == '-'):
                            push_param.append("\tpushq $"+par_words[1]+"\n")
                        elif par_words[1][0] == "*" and (par_words[1][1:] in classfields):
                            for x in reg:
                                if reg[x]==0:
                                    push_param.append("\tpushq "+classfields[par_words[1][1:]]+"("+x+")\n")
                                    push_param.append("\tmovq "+offset["this"]+"(%rbp),"+" "+x+"\n")
                                    break
                        elif par_words[1][0] == '*' and par_words[1][1] == '_':
                            push_param.append("\tpushq ("+var_reg[par_words[1][1:]]+")"+"\n")
                            reg[var_reg[par_words[1][1:]]] = 0
                        push_curr_param += 1
                    i += 1
                for x in reg:
                    if reg[x] == 1:
                        x86.append("\tpushq "+x+"\n")
                push_param.reverse()
                x86.extend(push_param)
                i -= 1
            elif "call" in words[0]:
                x86.append("\tcall "+words[1]+"\n")
                if (push_curr_param-6) > 0:
                    x86.append("\taddq $"+str(8*(push_curr_param-6))+", %rsp\n")
                push_curr_param = 1 
                push_list = []
                for x in reg:
                    if reg[x] == 1:
                        push_list.append(x)
                push_list.reverse()
                for x in push_list:
                    x86.append("\tpopq "+x+"\n")
            elif "goto" in words[0]:
                x86.append("\tjmp "+words[1]+"\n")
        elif len(words) == 3:
            if "stackbase" in words[2]:
                var_no += 1
                offset[words[0]] = "-"+str(var_no*8)
            elif "popparam" in words[2]:
                if pop_curr_param <= 6:
                    var_no += 1
                    x86.append("\tmovq "+param[pop_curr_param]+", -"+str(var_no*8)+"(%rbp)\n")
                    pop_curr_param += 1
                    offset[words[0]] = "-"+str(var_no*8)
                else :
                    offset[words[0]] = str(16 + 8*(pop_curr_param-7))
            elif words[0][0]=='_':
                if words[2] == "true":
                    if(words[0] not in var_reg):
                        for x in reg:
                            if reg[x]==0:
                                var_reg[words[0]] = x
                                reg[x] = 1
                                break
                    x86.append("\tmovq $1, "+var_reg[words[0]]+"\n")
                elif words[2] == "false":
                    if(words[0] not in var_reg):
                        for x in reg:
                            if reg[x]==0:
                                var_reg[words[0]] = x
                                reg[x] = 1
                                break
                    x86.append("\tmovq $0, "+var_reg[words[0]]+"\n")       
                elif ((ord(words[2][0])-ord('0'))<10 and (ord(words[2][0])-ord('0'))>-1)  or  (words[2][0] == '-'):
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq $"+words[2]+", "+x+"\n")
                            var_reg[words[0]] = x
                            reg[x] = 1
                            break
                elif words[2] in offset:
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq "+offset[words[2]]+"(%rbp),"+" "+x+"\n")
                            var_reg[words[0]] = x
                            reg[x] = 1
                            break
                elif words[2][0]=='_':
                    for x in reg:
                        if reg[x]==0:
                            x86.append("movq "+var_reg[words[2]]+", "+x+"\n")
                            var_reg[words[0]] = x
                            reg[x] = 1
                            reg[var_reg[words[2]]] = 0
                            break
                elif words[2][0] == "*" and (words[2][1:] in classfields):
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq "+offset["this"]+"(%rbp),"+" "+x+"\n")
                            reg[x] = 1
                            for y in reg:
                                if reg[x]==0:
                                    x86.append("\tmovq "+classfields[words[2][1:]]+"("+x+"), "+y+"\n")  
                                    var_reg[words[0]] = y
                                    reg[y] = 1
                                    reg[x] = 0
                                    break   
                            break
                elif words[2][0] == '*' and words[2][1] == '_':
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq ("+var_reg[words[2][1:]]+"), "+x+"\n")
                            reg[x] = 1
                            var_reg[words[0]] = x
                            reg[var_reg[words[2][1:]]] = 0
                            break
            elif words[0] in offset:
                if ((ord(words[2][0])-ord('0'))<10 and (ord(words[2][0])-ord('0'))>-1)  or  (words[2][0] == '-'):
                    x86.append("\tmovq $"+words[2]+", "+offset[words[0]]+"(%rbp)"+"\n")
                elif words[2] in offset:
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq "+offset[words[2]]+"(%rbp), "+x+"\n")
                            x86.append("\tmovq "+x+", "+offset[words[0]]+"(%rbp)"+"\n")
                            break
                elif words[2][0]=='_':
                    x86.append("\tmovq "+var_reg[words[2]]+", "+offset[words[0]]+"(%rbp)"+"\n")
                    reg[var_reg[words[2]]] = 0
                elif words[2][0] == "*" and (words[2][1:] in classfields):
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq "+offset["this"]+"(%rbp),"+" "+x+"\n")
                            reg[x]=1
                            for y in reg:
                                if reg[y]==0:
                                    x86.append("\tmovq "+classfields[words[2][1:]]+"("+x+"), "+y+"\n")
                                    x86.append("\tmovq "+y+", "+offset[words[0]]+"(%rbp)"+"\n") 
                                    reg[x] = 0
                                    break
                            break
                elif words[2][0] == '*' and words[2][1] == '_':
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq ("+var_reg[words[2][1:]]+"), "+x+"\n")
                            x86.append("\tmovq "+x+", "+offset[words[0]]+"(%rbp)"+"\n")
                            break
                    reg[var_reg[words[2][1:]]] = 0
            elif words[0][0] == "*" and (words[0][1:] in classfields):
                regthis = ""
                for x in reg:
                    if reg[x]==0:
                        x86.append("\tmovq "+offset["this"]+"(%rbp),"+" "+x+"\n")
                        regthis = x
                        reg[x] = 1
                        break
                if ((ord(words[2][0])-ord('0'))<10 and (ord(words[2][0])-ord('0'))>-1)  or  (words[2][0] == '-'):
                    x86.append("\tmovq $"+words[2]+", "+classfields[words[0][1:]]+"("+regthis+")"+"\n")
                elif words[2] in offset:
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq "+offset[words[2]]+"(%rbp), "+x+"\n")
                            x86.append("\tmovq "+x+", "+classfields[words[0][1:]]+"("+regthis+")"+"\n")
                            break
                elif words[2][0]=='_':
                    x86.append("\tmovq "+var_reg[words[2]]+", "+classfields[words[0][1:]]+"("+regthis+")"+"\n")
                    reg[var_reg[words[2]]] = 0
                elif words[2][0] == "*" and (words[2][1:] in classfields):
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq "+classfields[words[2][1:]]+"("+regthis+"), "+x+"\n")
                            x86.append("\tmovq "+x+", "+classfields[words[0][1:]]+"("+regthis+")"+"\n")

                elif words[2][0] == '*' and words[2][1] == '_':
                    x86.append("\tmovq ("+var_reg[words[2][1:]]+"), "+classfields[words[0][1:]]+"("+regthis+")"+"\n")
                    reg[var_reg[words[2][1:]]] = 0
                reg[regthis] = 0 
            elif words[0][0] == '*' and words[0][1] == '_':
                if ((ord(words[2][0])-ord('0'))<10 and (ord(words[2][0])-ord('0'))>-1)  or  (words[2][0] == '-'):
                    x86.append("\tmovq $"+words[2]+", ("+var_reg[words[0][1:]]+")\n")
                    reg[var_reg[words[0][1:]]] = 0
                elif words[2] in offset:
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq "+offset[words[2]]+"(%rbp), "+x+"\n")
                            x86.append("\tmovq "+x+", ("+var_reg[words[0][1:]]+")\n")
                            break
                    reg[var_reg[words[0][1:]]] = 0
                elif words[2][0] == '_':
                    x86.append("\tmovq "+var_reg[words[2]]+", ("+var_reg[words[0][1:]]+")\n")
                    reg[var_reg[words[2]]] = 0
                    reg[var_reg[words[0][1:]]] = 0
                elif words[2][0] == '*' and words[2][1] == '_':
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq ("+var_reg[words[0][1:]]+"), "+x+"\n")
                            x86.append("\tmovq "+x+", ("+var_reg[words[0][1:]]+")\n")
                            break
                    reg[var_reg[words[0][1:]]] = 0
                    reg[var_reg[words[2][1:]]] = 0
                elif words[2][0] == "*" and (words[2][1:] in classfields):
                    for x in reg:
                        if reg[x]==0:
                            reg[x]=1
                            for y in reg:
                                if reg[y]==0:
                                    x86.append("\tmovq "+classfields[words[2][1:]]+"("+x+"), "+y+"\n")
                                    x86.append("\tmovq "+y+", ("+var_reg[words[0][1:]]+")\n")
                                    reg[x]=0
                                    break
                        break
        elif len(words) == 4:
            if "call" in words[2]:
                if "allocmem" in words[3]:
                    x86.append("\tcall malloc@PLT\n")
                else:
                    x86.append("\tcall "+words[3]+"\n")
                push_list = []
                for x in reg:
                    if reg[x] == 1:
                        push_list.append(x)
                if words[0][0] == '_':
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq %rax, "+x+"\n")
                            reg[x] = 1
                            var_reg[words[0]] = x
                            break
                elif words[0] in offset:
                    x86.append("\tmovq %rax, "+offset[words[0]]+"(%rbp)\n")
                elif words[0][0] == "*" and (words[0][1:] in classfields):
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq "+offset["this"]+"(%rbp),"+" "+x+"\n")
                            x86.append("\tmovq "+"%rax, "+classfields[words[0][1:]]+"("+x+")"+"\n")
                            break
                if (push_curr_param-6) > 0:
                    x86.append("\taddq $"+str(8*(push_curr_param-6))+", %rsp\n")
                push_curr_param = 1
                push_list.reverse()
                for x in push_list:
                    x86.append("\tpopq "+x+"\n")
            elif "=" in words[1]:
                r = ""
                if words[3][0] == '_':
                    r = var_reg[words[3]]
                elif words[3] in offset:
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq "+offset[words[3]]+"(%rbp), "+x+"\n")
                            reg[x]=1
                            r = x
                            break
                elif ((ord(words[3][0])-ord('0'))<10 and (ord(words[3][0])-ord('0'))>-1)  or  (words[3][0] == '-'):
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq $"+words[3]+", "+x+"\n")
                            reg[x]=1
                            r = x
                            break
                elif words[3][0] == "*" and (words[3][1:] in classfields):
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq "+offset["this"]+"(%rbp),"+" "+x+"\n")
                            reg[x] = 1
                            for y in reg:
                                if reg[x]==0:
                                    x86.append("\tmovq "+classfields[words[3][1:]]+"("+x+"), "+y+"\n")  
                                    r = y
                                    reg[y] = 1
                                    reg[x] = 0
                                    break   
                            break
                var_reg[words[0]] = r
                if words[2][0] == "-":
                    x86.append("\tneg "+ r+"\n")
                elif words[2][0] == "~":
                    x86.append("\tnot "+ r+"\n")
            elif "if" == words[0] :
                if words[1] in cond:
                    x86.append("\t"+cond[words[1]][1]+" "+words[3]+"\n")
                    del cond[words[1]]
                else:
                    x86.append("\tcmp $1, "+var_reg[words[1]]+"\n")
                    x86.append("\tje "+words[3]+"\n")
                    reg[var_reg[words[1]]] = 0
            elif "ifFalse" == words[0] :
                if words[1] in cond:
                    x86.append("\t"+cond[words[1]][0]+" "+words[3]+"\n")
                    del cond[words[1]]
                else:
                    x86.append("\tcmp $0, "+var_reg[words[1]]+"\n")
                    x86.append("\tje "+words[3]+"\n")
                    reg[var_reg[words[1]]] = 0
        elif len(words) == 5:
            reg_list = [""]*2
            if "this" in words[2]:
                classfields[words[0]] = str(classoff*8)
                classoff += 1
            elif words[4][0] == '_':
                reg_list[1] = var_reg[words[4]]
            elif words[4] in offset:
                for x in reg:
                    if reg[x]==0:
                        x86.append("\tmovq "+offset[words[4]]+"(%rbp), "+x+"\n")
                        reg[x]=1
                        reg_list[1] = x
                        break
            elif ((ord(words[4][0])-ord('0'))<10 and (ord(words[4][0])-ord('0'))>-1)  or  (words[4][0] == '-'):
                for x in reg:
                    if reg[x]==0:
                        x86.append("\tmovq $"+words[4]+", "+x+"\n")
                        reg[x]=1
                        reg_list[1] = x
                        break
            elif words[4][0] == "*" and (words[4][1:] in classfields):
                for x in reg:
                    if reg[x]==0:
                        x86.append("\tmovq "+offset["this"]+"(%rbp),"+" "+x+"\n")
                        reg[x] = 1
                        for y in reg:
                            if reg[x]==0:
                                x86.append("\tmovq "+classfields[words[4][1:]]+"("+x+"), "+y+"\n")  
                                reg_list[1] = y
                                reg[y] = 1
                                reg[x] = 0
                                break   
                        break
            if ("this" not in words[2]):
                if words[2][0] == '_' :
                    reg_list[0] = var_reg[words[2]]
                elif words[2] in offset:
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq "+offset[words[2]]+"(%rbp), "+x+"\n")
                            reg[x]=1
                            reg_list[0] = x
                            break
                elif ((ord(words[2][0])-ord('0'))<10 and (ord(words[2][0])-ord('0'))>-1)  or  (words[2][0] == '-'):
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq $"+words[2]+", "+x+"\n")
                            reg[x]=1
                            reg_list[0] = x
                            break
                elif words[2][0] == "*" and (words[2][1:] in classfields):
                    for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq "+offset["this"]+"(%rbp),"+" "+x+"\n")
                            reg[x] = 1
                            for y in reg:
                                if reg[x]==0:
                                    x86.append("\tmovq "+classfields[words[2][1:]]+"("+x+"), "+y+"\n")  
                                    reg_list[0] = y
                                    reg[y] = 1
                                    reg[x] = 0
                                    break   
                            break
            if words[3] == "&":
                x86.append("\tand "+reg_list[1]+", "+reg_list[0]+"\n")
                var_reg[words[0]] = reg_list[0] 
            elif words[3] == "|":
                x86.append("\tor "+reg_list[1]+", "+reg_list[0]+"\n")
                var_reg[words[0]] = reg_list[0] 
            elif words[3] == "^":
                x86.append("\txor "+reg_list[1]+", "+reg_list[0]+"\n")
                var_reg[words[0]] = reg_list[0] 
            elif words[3] == "<<":
                x86.append("\tsal "+reg_list[1]+", "+reg_list[0]+"\n")
                var_reg[words[0]] = reg_list[0] 
            elif words[3] == ">>":
                x86.append("\tsar "+reg_list[1]+", "+reg_list[0]+"\n")
                var_reg[words[0]] = reg_list[0] 
            elif words[3] == ">>>":
                x86.append("\tshr "+reg_list[1]+", "+reg_list[0]+"\n")
                var_reg[words[0]] = reg_list[0] 
            else:
                if words[3] == "<":
                    x86.append("\tcmp "+reg_list[1]+", "+reg_list[0]+"\n")
                    cond[words[0]] = ["jge","jl"]
                elif words[3] == "<=":
                    x86.append("\tcmp "+reg_list[1]+", "+reg_list[0]+"\n")
                    cond[words[0]] = ["jg","jle"]
                elif words[3] == ">":
                    x86.append("\tcmp "+reg_list[1]+", "+reg_list[0]+"\n")
                    cond[words[0]] = ["jle","jg"]
                elif words[3] == ">=":
                    x86.append("\tcmp "+reg_list[1]+", "+reg_list[0]+"\n")
                    cond[words[0]] = ["jl","jge"]
                elif words[3] == "==":
                    x86.append("\tcmp "+reg_list[1]+", "+reg_list[0]+"\n")
                    cond[words[0]] = ["jne","je"]
                elif words[3] == "!=":
                    x86.append("\tcmp "+reg_list[1]+", "+reg_list[0]+"\n")
                    cond[words[0]] = ["je","jne"]
                reg[reg_list[0]] = 0
            reg[reg_list[1]] = 0          
        elif len(words) == 6:
            reg_list = [""]*2

            if words[5][0] == '_':
                reg_list[1] = var_reg[words[5]]
            elif words[5] in offset:
                for x in reg:
                    if reg[x]==0:
                        x86.append("\tmovq "+offset[words[5]]+"(%rbp), "+x+"\n")
                        reg[x]=1
                        reg_list[1] = x
                        break
            elif ((ord(words[5][0])-ord('0'))<10 and (ord(words[5][0])-ord('0'))>-1)  or  (words[5][0] == '-'):
                for x in reg:
                    if reg[x]==0:
                        x86.append("\tmovq $"+words[5]+", "+x+"\n")
                        reg[x]=1
                        reg_list[1] = x
                        break
            elif words[5][0]=='*' and words[5][1]=='_':
                for x in reg:
                    if reg[x]==0:
                        x86.append("\tmovq ("+var_reg[words[5][1:]]+"), "+x+"\n")
                        reg[var_reg[words[5][1:]]] = 0
                        reg[x]=1
                        reg_list[1] = x
                        break
            elif words[5][0] == "*" and (words[5][1:] in classfields):
                for x in reg:
                    if reg[x]==0:
                        x86.append("\tmovq "+offset["this"]+"(%rbp),"+" "+x+"\n")
                        reg[x] = 1
                        for y in reg:
                            if reg[x]==0:
                                x86.append("\tmovq "+classfields[words[5][1:]]+"("+x+"), "+y+"\n")  
                                reg_list[1] = y
                                reg[y] = 1
                                reg[x] = 0
                                break   
                        break

            if words[2][0] == '_':
                reg_list[0] = var_reg[words[2]]
            elif words[2] in offset:
                for x in reg:
                    if reg[x]==0:
                        x86.append("\tmovq "+offset[words[2]]+"(%rbp), "+x+"\n")
                        reg[x]=1
                        reg_list[0] = x
                        break
            elif ((ord(words[2][0])-ord('0'))<10 and (ord(words[2][0])-ord('0'))>-1)  or  (words[2][0] == '-'):
                for x in reg:
                    if reg[x]==0:
                        x86.append("\tmovq $"+words[2]+", "+x+"\n")
                        reg[x]=1
                        reg_list[0] = x
                        break
            elif words[2][0] == '*' and words[2][1] == '_':
                for x in reg:
                    if reg[x]==0:
                        x86.append("\tmovq ("+var_reg[words[2][1:]]+"), "+x+"\n")
                        reg[var_reg[words[2][1:]]] = 0
                        reg[x]=1
                        reg_list[0] = x
                        break
            elif words[2][0] == "*" and (words[2][1:] in classfields):
                for x in reg:
                    if reg[x]==0:
                        x86.append("\tmovq "+offset["this"]+"(%rbp),"+" "+x+"\n")
                        reg[x] = 1
                        for y in reg:
                            if reg[x]==0:
                                x86.append("\tmovq "+classfields[words[2][1:]]+"("+x+"), "+y+"\n")  
                                reg_list[0] = y
                                reg[y] = 1
                                reg[x] = 0
                                break   
                        break

            if words[3][0] == '+':
                x86.append("\taddq "+reg_list[1]+", "+reg_list[0]+"\n")
            elif words[3][0] == '-':
                x86.append("\tsubq "+reg_list[1]+", "+reg_list[0]+"\n")
            elif words[3][0] == '*':
                if reg["%rax"]==0:
                    x86.append("\tmovq "+reg_list[0]+", "+"%rax"+"\n")
                    x86.append("\timulq "+reg_list[1]+"\n")
                    x86.append("\tmovq %rax, "+reg_list[0]+"\n")
                elif reg_list[0]=="%rax":
                    x86.append("\timulq "+reg_list[1]+"\n")
                elif reg_list[1]=="%rax":
                    x86.append("\timulq "+reg_list[0]+"\n")
                    x86.append("\tmovq %rax, "+reg_list[0]+"\n")
                else:
                    free_reg = ""
                    for x in reg:
                        if reg[x]==0:
                            free_reg = x
                            break
                    x86.append("\tmovq %rax, "+x+"\n")
                    x86.append("\tmovq "+reg_list[0]+", "+"%rax"+"\n")
                    x86.append("\timulq "+reg_list[1]+"\n")
                    x86.append("\tmovq %rax, "+reg_list[0]+"\n")
                    x86.append("\tmovq "+x+", %rax"+"\n")
            elif words[3][0] == '/' :
                flag = ""
                if reg["%rdx"]==0:
                    x86.append("\tmovq $0, %rdx"+"\n")
                else:
                    free_reg = ""
                    for x in reg:
                        if reg[x]==0:
                            free_reg = x
                            break
                    x86.append("\tmovq %rdx, "+x+"\n")
                    x86.append("\tmovq $0, %rdx"+"\n")
                    flag = x
                    reg[x]=1
                reg["%rdx"]=1
                if reg["%rax"]==0:
                    x86.append("\tmovq "+reg_list[0]+", "+"%rax"+"\n")
                    x86.append("\tcqto\n\tidivq "+reg_list[1]+"\n")
                    x86.append("\tmovq %rax, "+reg_list[0]+"\n")
                elif reg_list[0]=="%rax":
                    x86.append("\tcqto\n\tidivq "+reg_list[1]+"\n")
                elif reg_list[1]=="%rax":
                    free_reg = ""
                    for x in reg:
                        if reg[x]==0:
                            free_reg = x
                            break
                    x86.append("\tmovq %rax, "+x+"\n")
                    x86.append("\tmovq "+reg_list[0]+", "+"%rax"+"\n")
                    x86.append("\tcqto\n\tidivq "+x+"\n")
                    x86.append("\tmovq %rax, "+reg_list[0]+"\n")
                else:
                    free_reg = ""
                    for x in reg:
                        if reg[x]==0:
                            free_reg = x
                            break
                    x86.append("\tmovq %rax, "+x+"\n")
                    x86.append("\tmovq "+reg_list[0]+", "+"%rax"+"\n")
                    x86.append("\tcqto\n\tidivq "+reg_list[1]+"\n")
                    x86.append("\tmovq %rax, "+reg_list[0]+"\n")
                    x86.append("\tmovq "+x+", %rax"+"\n")
                if(flag != ""):
                    x86.append("\tmovq "+x+", %rdx"+"\n")
                    reg[x]=0
            elif words[3][0] == '%' :
                flag = ""
                if reg["%rdx"]==0:
                    x86.append("\tmovq $0, %rdx"+"\n")
                else:
                    free_reg = ""
                    for x in reg:
                        if reg[x]==0:
                            free_reg = x
                            break
                    x86.append("\tmovq %rdx, "+x+"\n")
                    x86.append("\tmovq $0, %rdx"+"\n")
                    flag = x
                    reg[x]=1
                reg["%rdx"]=1
                if reg["%rax"]==0:
                    x86.append("\tmovq "+reg_list[0]+", "+"%rax"+"\n")
                    x86.append("\tcqto\n\tidivq "+reg_list[1]+"\n")
                    x86.append("\tmovq %rdx, "+reg_list[0]+"\n")
                elif reg_list[0]=="%rax":
                    x86.append("\tcqto\n\tidivq "+reg_list[1]+"\n")
                    x86.append("\tmovq %rdx, "+reg_list[0]+"\n")
                elif reg_list[1]=="%rax":
                    free_reg = ""
                    for x in reg:
                        if reg[x]==0:
                            free_reg = x
                            break
                    x86.append("\tmovq %rax, "+x+"\n")
                    x86.append("\tmovq "+reg_list[0]+", "+"%rax"+"\n")
                    x86.append("\tcqto\n\tidivq "+x+"\n")
                    x86.append("\tmovq %rdx, "+reg_list[0]+"\n")
                else:
                    free_reg = ""
                    for x in reg:
                        if reg[x]==0:
                            free_reg = x
                            break
                    x86.append("\tmovq %rax, "+x+"\n")
                    x86.append("\tmovq "+reg_list[0]+", "+"%rax"+"\n")
                    x86.append("\tcqto\n\tidivq "+reg_list[1]+"\n")
                    x86.append("\tmovq %rdx, "+reg_list[0]+"\n")
                    x86.append("\tmovq "+x+", %rax"+"\n")
                if(flag != ""):
                    x86.append("\tmovq "+x+", %rdx"+"\n")
                    reg[x]=0
                

            if words[0][0] == '_':
                var_reg[words[0]] = reg_list[0]
                reg[reg_list[1]] = 0
            elif words[0] in offset:
                x86.append("\tmovq "+reg_list[0]+", "+offset[words[0]]+"(%rbp)"+"\n")
                reg[reg_list[0]] = 0
                reg[reg_list[1]] = 0
            elif words[0][0] == '*' and words[0][1] == '_':
                x86.append("\tmovq "+reg_list[0]+", ("+var_reg[words[0][-1]]+")"+"\n")
                reg[reg_list[0]] = 0
                reg[reg_list[1]] = 0
            elif words[0][0] == "*" and (words[0][1:] in classfields):
                for x in reg:
                        if reg[x]==0:
                            x86.append("\tmovq "+offset["this"]+"(%rbp),"+" "+x+"\n")
                            x86.append("\tmovq "+reg_list[0]+", "+classfields[words[0][1:]]+"("+x+")"+"\n")
                            break
                reg[reg_list[0]] = 0
                reg[reg_list[1]] = 0
        i += 1

    if stack_space_line != -1:
        x86[stack_space_line] = "\tsubq $"+str(8*(var_no+1))+", %rsp\n"
    
    if not("ret" in x86[-1]):
        x86.append("\tleave\n\tret\n")

for x in x86:
    outfile.write(x)


# print(offset)
# print(reg)
# print(var_reg)
