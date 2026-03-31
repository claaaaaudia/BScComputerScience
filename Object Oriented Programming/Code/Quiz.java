package Codigo;
import java.util.ArrayList;

public class Quiz
{
    private ArrayList<Questao> questoes;
    
    public Quiz() {
        this.questoes = new ArrayList<Questao>();
    }
    public Quiz(ArrayList<Questao> questoes) {
        this.questoes = questoes;
    }
    public Quiz(Quiz q) {
        this.questoes = q.getQuestoes();
    }
    
    public ArrayList<Questao> getQuestoes() {
        return questoes; 
    }
    public void setQuestoes(ArrayList<Questao> questoes) {
        this.questoes = questoes; 
    }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Quiz quiz = (Quiz) o;
        return this.questoes.equals(quiz.getQuestoes());
    }
    @Override
    public String toString() {
        return "Quiz{" + "questões = "  + questoes + "}";
    }
    @Override
    public Quiz clone() {
        return new Quiz(this);
    }
    
    public int calculaResultadoQuiz() {
        int total = 0;
        for (Questao q: this.questoes) {
            if (q instanceof EscolhaMultipla) {
                EscolhaMultipla em = (EscolhaMultipla) q;
                total += em.getResposta();
            } else if (q instanceof VouF) {
                VouF vf = (VouF) q;
                total += vf.valorResposta();
            }
        }
        return total;
    }
    public int takeQuiz() {
        int total = calculaResultadoQuiz();
        if (total < 5) { 
            return 0; //amador
        }
        else if (total < 11) {
            return 1; //casual
        }
        else {
            return 2; //profissional
        }
    }
}
