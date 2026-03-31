package Codigo;
public class Questao
{
    private String questao; //se for EM é preciso incluir as opções (em comentário na subclasse)
                            //se for VouF é preciso pedir o formato S/N
    
    public Questao() {
        this.questao = null;
    }
    public Questao(String questao) {
        this.questao = questao;
    }
    public Questao(Questao q) {
        this.questao = q.getQuestao();
    }
    
    public String getQuestao() {
        return questao; 
    }
    public void setQuestao(String questao) {
        this.questao = questao; 
    }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Questao questao = (Questao) o;
        return this.questao.equals(questao.getQuestao());
    }
    @Override
    public String toString() {
        return "Questão: " + questao;
    }
    @Override
    public Questao clone() {
        return new Questao(this);
    }
}
