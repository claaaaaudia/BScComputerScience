import sys
import ply.yacc as yacc
import ply.lex as lexer
from lexer import tokens

def p_Programa1(p):
    """Programa : Declaracoes Funcoes"""
    main_code = f'{p[1]}START\n{p[2]}STOP\n'
    func_code = ''.join(parser.functions.values()) 
    parser.VMcode = main_code + func_code

def p_Declaracoes1(p):
    """Declaracoes : Declaracao"""
    p[0] = f'{p[1]}' 

def p_Declaracoes2(p):
    """Declaracoes : Declaracoes Declaracao"""
    p[0] = f'{p[1]}{p[2]}'

def p_Funcoes1(p):
    """Funcoes : Funcao"""
    p[0] = f'{p[1]}' 

def p_Funcoes2(p):
    """Funcoes : Funcoes Funcao"""
    p[0] = f'{p[1]}{p[2]}'

def p_Funcao1(p):
    """Funcao : Selecao"""
    p[0] = f'{p[1]}' 

def p_Funcao2(p):
    """Funcao : Ciclo"""
    p[0] = f'{p[1]}' 

def p_Funcao3(p):
    """Funcao : Subprograma"""
    p[0] = f'{p[1]}' 

def p_Funcao4(p):
    """Funcao : Atribuicao"""
    p[0] = f'{p[1]}' 

def p_Funcao5(p):
    """Funcao : Print"""
    p[0] = f'{p[1]}' 

def p_Funcao6(p):
    """Funcao : ChamadaFuncao"""
    p[0] = f'{p[1]}' 

def p_Declaracao(p):
    """Declaracao : INT VAR"""
    if p[2] not in parser.tabids:
        parser.tabids[p[2]] = len(parser.tabids)  # Aloca espaço na tabela de símbolos
        p[0] = f'PUSHI 0\n'
    else:
        print(f"Erro semântico: Variável {p[2]} já declarada.")
        parser.success = False

def p_Atribuicao1(p):
    """Atribuicao : VAR IGUAL Expressao"""
    if p[1] in parser.tabids:
        p[0] = f'{p[3]}STOREG {parser.tabids[p[1]]}\n'
    else:
        print(f"Erro semântico: Variável {p[1]} não foi declarada.")
        parser.success = False

def p_Atribuicao2(p): # Receber input!!
    """Atribuicao : VAR IGUAL INPUT"""
    if p[1] in parser.tabids:
        p[0] = f'READ\nATOI\nSTOREG {parser.tabids.get(p[1])}\n'
    else:
        print(f"Erro semântico: Variável {p[1]} não foi declarada.")
        parser.success = False

def p_Expressao1(p):
    """Expressao : Operacao"""
    p[0] = f'{p[1]}'

def p_Expressao2(p):
    """Expressao : NUM"""
    p[0] = f'PUSHI {p[1]}\n'

def p_Expressao3(p):
    """Expressao : VAR"""
    if p[1] in parser.tabids:
        p[0] = f'PUSHG {parser.tabids[p[1]]}\n'
    else:
        print(f"Erro semântico: Variável {p[1]} não foi declarada.")
        parser.success = False

def p_Expressao4(p):
    """Expressao : ChamadaFuncao"""
    p[0] = f'{p[1]}'

def p_Operacao(p):
    """Operacao : Expressao Operador Expressao """
    p[0] = f'{p[1]}{p[3]}{p[2]}'

def p_Operador1(p):
    """Operador : VEZES"""
    p[0] = f'MUL\n'

def p_Operador2(p):
    """Operador : MAIS"""
    p[0] = f'ADD\n'

def p_Operador3(p):
    """Operador : MENOS"""
    p[0] = f'SUB\n'

def p_Operador4(p):
    """Operador : DIV"""
    p[0] = f'DIV\n'

def p_Operador5(p):
    """Operador : MOD"""
    p[0] = f'MOD\n'

def p_Comparador1(p):
    """Comparador : MAIOR"""
    p[0] = f'SUP\n'

def p_Comparador2(p):
    """Comparador : MENOR"""
    p[0] = f'INF\n'

def p_Comparador3(p):
    """Comparador : MAIOR IGUAL"""
    p[0] = f'SUPEQ\n'

def p_Comparador4(p):
    """Comparador : MENOR IGUAL"""
    p[0] = f'INFEQ\n'

def p_Comparador5(p):
    """Comparador : NAO IGUAL"""
    p[0] = f'EQUAL\nNOT\n'

def p_Comparador6(p):
    """Comparador : IGUAL IGUAL"""
    p[0] = f'EQUAL\n'

def p_Selecao1(p):
    """Selecao : IF Condicao DOISPT Corpo ELSE DOISPT Corpo ENDELSE ENDIF"""
    p[0] = f'{p[2]}JZ label{p.parser.labels}\n{p[4]}JUMP label{p.parser.labels}f\nlabel{p.parser.labels}: NOP\n{p[7]}label{p.parser.labels}f: NOP\n'
    p.parser.labels += 1

def p_Selecao2(p):
    """Selecao : IF Condicao DOISPT Corpo ENDIF"""
    p[0] = f'{p[2]}JZ label{p.parser.labels}\n{p[4]}label{p.parser.labels}: NOP\n'
    p.parser.labels += 1

def p_Ciclo(p):
    """Ciclo : WHILE Condicao DOISPT Corpo ENDWHILE"""
    p[0] = f'label{p.parser.labels}c: NOP\n{p[2]}JZ label{p.parser.labels}f\n{p[4]}JUMP label{p.parser.labels}c\nlabel{p.parser.labels}f: NOP\n'
    p.parser.labels += 1

def p_Condicao1(p):
    """Condicao : LPAREN Expressao Comparador Expressao RPAREN"""
    p[0] = f'{p[2]}{p[4]}{p[3]}'

def p_Condicao2(p):
    """Condicao : LPAREN Condicao AND Condicao RPAREN"""
    p[0] = f'{p[2]}{p[4]}AND\n'

def p_Condicao3(p):
    """Condicao : LPAREN Condicao OR Condicao RPAREN"""
    p[0] = f'{p[2]}{p[4]}OR\n'

def p_Condicao4(p):
    """Condicao : LPAREN NAO Condicao RPAREN"""
    p[0] = f'NOT\n{p[2]}'

def p_Condicao5(p):
    """Condicao : LPAREN Condicao RPAREN"""
    p[0] = f'{p[2]}'

def p_Subprograma(p):
    """Subprograma : DEFINE F DOISPT Corpo RETURN VAR ENDDEFINE"""
    if p[6] in parser.tabids:
        func_code = f'{p[2]}:\n{p[4]}PUSHG {parser.tabids[p[6]]}\nRETURN\n'
        parser.functions[p[2]] = func_code  
        p[0] = ''
    else:
        print(f"Erro semântico: Variável {p[6]} não foi declarada.")
        parser.success = False

def p_Corpo1(p):
    """Corpo : C Corpo"""
    p[0] = f'{p[1]}{p[2]}'

def p_Corpo2(p):
    """Corpo : C"""
    p[0] = f'{p[1]}'

def p_C1(p):
    """C : Selecao"""
    p[0] = f'{p[1]}'

def p_C2(p):
    """C : Atribuicao"""
    p[0] = f'{p[1]}'

def p_C3(p):
    """C : Ciclo"""
    p[0] = f'{p[1]}'

def p_C4(p):
    """C : ChamadaFuncao"""
    p[0] = f'{p[1]}'

def p_C5(p):
    """C : Print"""
    p[0] = f'{p[1]}'

def p_F(p):
    """F : PALAVRA LPAREN RPAREN"""
    p[0] = f'{p[1]}'

def p_ChamadaFuncao(p):
    """ChamadaFuncao : F"""
    nome = f'{p[1]}'
    if nome in parser.functions:
        p[0] = f'PUSHA {p[1]}\nCALL\n'
    else:
        print(f"Erro semântico: Função {p[1]} não foi declarada.")
        parser.success = False

def p_VAR(p):
    """VAR : PALAVRA"""
    p[0] = f'{p[1]}'

def p_Print1(p):
    """Print : PRINT LPAREN STRING RPAREN"""
    p[0] = f'PUSHS {p[3]}\nWRITES\nWRITELN\n'

def p_Print2(p):
    """Print : PRINT LPAREN VAR RPAREN"""
    p[0] = f'PUSHG {parser.tabids.get(p[3])}\nWRITEI\nWRITELN\n'

# Tratamento de erro
def p_error(p):
    print("Erro Sintático! Reescreva a frase.", p)
    parser.success = False

# Construir o parser
vm_code = []
parser = yacc.yacc()
parser.success = True
parser.tabids = {}
parser.functions = {}
parser.labels = 0
parser.VMcode = ""

x = input("Escolha o teste.")
with open(f'testes/teste{x}.txt', "r") as f:
    content = f.read()

lexer.input(content)
parser.parse(lexer=lexer)

if parser.success:
    print("Parsing feito com sucesso.")
    with open(f'testesVM/teste{x}.vm', 'w+') as f_out:
        f_out.write(parser.VMcode)
        f_out.close()
    print("Código VM gerado e guardado no ficheiro.")
else:
    print("Não foi possível gerar o código VM.")
