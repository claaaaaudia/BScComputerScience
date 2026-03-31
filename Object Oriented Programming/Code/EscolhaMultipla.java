package Codigo;
/**
       Do género:
       
       [Pergunta]?
       1. Nunca
       2. Raramente
       3. Às vezes
       4. Muitas vezes
       5. Sempre
       
       no total acrescenta o valor (ex: se sempre, total += 5)
*/

public class EscolhaMultipla extends Questao
{
    private int resposta;
    
    public EscolhaMultipla() {
        super();
        this.resposta = 0;
    }
    public EscolhaMultipla(String questao, int resposta) {
        super(questao);
        this.resposta = resposta;
    }
    public EscolhaMultipla(EscolhaMultipla outra) {
        super(outra);
        this.resposta = outra.getResposta();
    }
    
    public int getResposta() {
        return resposta;
    }
    public void setResposta(int resposta) {
        this.resposta = resposta;
    }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;
        EscolhaMultipla escolha = (EscolhaMultipla) o;
        return this.resposta == escolha.getResposta();
    }
    @Override
    public String toString() {
        return super.toString() + " / Resposta: " + resposta;
    }
    @Override
    public Questao clone() {
        return new EscolhaMultipla(this);
    }
}
