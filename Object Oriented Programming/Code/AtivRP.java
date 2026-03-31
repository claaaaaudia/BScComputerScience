package Codigo;
import java.time.LocalDate;
import java.util.ArrayList;


public class AtivRP extends Atividade
{
    private int repeticoes; //quantas repeticoes
    private int intervalo; //intervalo entre repeticoes?
    private int peso;
    
    public AtivRP() {
        super();
        this.repeticoes = 0;
        this.intervalo = 0;
        this.peso = 0;
    }
    public AtivRP(String descricao, String idAtiv, LocalDate dataRealizacao, int duracao, boolean hard, double FCM, ArrayList<Utilizador> utilizadores, int repeticoes, int intervalo, int peso) {
        super(descricao, idAtiv, dataRealizacao, duracao, hard, FCM, utilizadores);
        this.repeticoes = repeticoes;
        this.intervalo = intervalo;
        this.peso = peso;
    }
    public AtivRP(AtivRP outro) {
        super(outro);
        this.repeticoes = getRepeticoes();
        this.intervalo = getIntervalo();
        this.peso = getPeso();
    }
    
    //sets
    public int getRepeticoes() {
        return repeticoes;
    }
    public int getIntervalo() {
        return intervalo;
    }
    public int getPeso() {
        return peso;
    }
    
    //gets
    public void setRepeticoes(int repeticoes) {
        this.repeticoes = repeticoes;
    }
    public void setIntervalo(int intervalo) {
        this.intervalo = intervalo;
    }
    public void setPeso(int peso) {
        this.peso = peso;
    }
    
    /** método que calcula as calorias gastas */
    @Override 
    public double calorias_queimadas(Utilizador u){
        return u.calculaMulCalorias() + this.repeticoes * this.peso * 0.2 + u.calculaIdade(getDataRealizacao()) * 0.2  - 55 / 4;
    }
    
    //metodos
    @Override
    public Atividade clone() {
        return new AtivRP(this);
    }
    @Override
    public String toString() {
        return super.toString() +
                "\nRepetições: " + repeticoes +
                "\nIntervalo: " + intervalo +
                "\nPeso: " + peso;
    }
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;
        AtivRP ativ = (AtivRP) o;
        return ativ.getRepeticoes() == getRepeticoes()
                && ativ.getIntervalo() == getIntervalo()
                && ativ.getPeso() == getPeso();
    }
}
