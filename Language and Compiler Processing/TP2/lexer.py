import ply.lex as lex
import sys

tokens = (
    'AND',
    'OR',
    'LPAREN',
    'RPAREN',
    'DOISPT',
    'DIV',
    'MOD',
    'IGUAL',
    'MAIS',
    'MENOS',
    'VEZES',
    'IF',
    'ENDIF',
    'ELSE',
    'ENDELSE',
    'MAIOR',
    'MENOR',
    'DEFINE',
    'ENDDEFINE',
    'WHILE',
    'ENDWHILE',
    'RETURN',
    'INT',
    'NAO',
    'INPUT',
    'PRINT',
    'STRING',
    'NUM',
    'PALAVRA'
)

t_LPAREN = r'\('
t_RPAREN = r'\)'
t_DOISPT = r':'
t_IGUAL  = r'='
t_MAIS   = r'\+'
t_DIV    = r'/'
t_MOD    = r'%'
t_MENOS  = r'-'
t_VEZES  = r'\*'
t_MAIOR  = r'>'
t_MENOR  = r'<'
t_NAO    = r'!'

def t_AND(t):
    r'and'
    return t

def t_OR(t):
    r'or'
    return t

def t_DEFINE(t):
    r'define'
    return t

def t_ENDDEFINE(t):
    r'enddefine'
    return t

def t_IF(t):
    r'if'
    return t

def t_ENDIF(t):
    r'endif'
    return t

def t_ELSE(t):
    r'else'
    return t

def t_ENDELSE(t):
    r'endelse'
    return t

def t_WHILE(t):
    r'while'
    return t

def t_ENDWHILE(t):
    r'endwhile'
    return t

def t_RETURN(t):
    r'return'
    return t

def t_INT(t):
    r'int'
    return t

def t_INPUT(t):
    r'input'
    return t

def t_PRINT(t):
    r'print'
    return t

def t_STRING(t):
    r'\".+\"'
    return t

def t_NUM(t):
    r'\d+'
    t.value = int(t.value)
    return t

def t_PALAVRA(t):
    r'[a-zA-Z][a-zA-Z0-9]*'
    return t

t_ignore = ' \t\n'

def t_error(t):
    print('Illegal character: ', t.value[0])
    t.lexer.skip(1)

x = input("Escolha o teste.")
with open(f'testes/teste{x}.txt', "r") as f:
    content = f.read()

lexer = lex.lex()
lexer.input(content)

def test_lexer():
    for linha in content.splitlines(): 
        lexer.input(linha)  
        for tok in lexer:  
            print(tok)

test_lexer()
