package Codigo;
import java.time.LocalDate;
import java.util.ArrayList;


public class AtivR extends Atividade
{
    private int repeticoes; //quantas repeticoes
    private int intervalo; //intervalo entre repeticoes?
    
    public AtivR() {
        super();
        this.repeticoes = 0;
        this.intervalo = 0;
    }
    public AtivR(String descricao, String idAtiv, LocalDate dataRealizacao, int duracao, boolean hard, double FCM, ArrayList<Utilizador> utilizadores, int repeticoes, int intervalo) {
        super(descricao, idAtiv, dataRealizacao, duracao, hard, FCM, utilizadores);
        this.repeticoes = repeticoes;
        this.intervalo = intervalo;
    }
    public AtivR(AtivR outro) {
        super(outro);
        this.repeticoes = getRepeticoes();
        this.intervalo = getIntervalo();
    }
    
    //sets
    public int getRepeticoes() {
        return repeticoes;
    }
    public int getIntervalo() {
        return intervalo;
    }
    
    //gets
    public void setRepeticoes(int repeticoes) {
        this.repeticoes = repeticoes;
    }
    public void setIntervalo(int intervalo) {
        this.intervalo = intervalo;
    }
    
    /** método que calcula as calorias gastas */
    @Override
    public double calorias_queimadas(Utilizador u){
        return u.calculaMulCalorias() + this.repeticoes * 0.2 + u.calculaIdade(getDataRealizacao()) * 0.2  - 55 / 4;
    }
    
    //metodos
    @Override
    public Atividade clone() {
        return new AtivR(this);
    }
    @Override
    public String toString() {
        return super.toString()+
                "\nRepetições: " + repeticoes +
                "\nIntervalo: " + intervalo;
    }
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;
        AtivR ativ = (AtivR) o;
        return ativ.getRepeticoes() == getRepeticoes()
                && ativ.getIntervalo() == getIntervalo();
    }
}
