package Codigo;
/**
       Do género:
       
       [Pergunta]?
       1. Não
       2. Sim
       
       no total acrescenta o valor (se sim: total += 2, se não: total += 0)
*/

public class VouF extends Questao
{
    private boolean resposta;
    
    public VouF() {
        super();
        this.resposta = false;
    }
    public VouF(String questao, boolean resposta) {
        super(questao);
        this.resposta = resposta;
    }
    public VouF(VouF outra) {
        super(outra);
        this.resposta = outra.getResposta(); 
    }
    
    public boolean getResposta() {
        return resposta;
    }
    public void setResposta(boolean resposta) {
        this.resposta = resposta;
    }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;
        VouF vouf = (VouF) o;
        return this.resposta == vouf.getResposta();
    }
    @Override
    public String toString() {
        return super.toString() + " / Resposta: " + resposta;
    }
    @Override
    public Questao clone() {
        return new VouF(this);
    }
    
    public int valorResposta() {
        if (this.resposta == true) return 2;
        return 0;
    }
}
