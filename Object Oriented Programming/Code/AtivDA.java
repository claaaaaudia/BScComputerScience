package Codigo;
import java.time.LocalDate;
import java.util.ArrayList;

public class AtivDA extends Atividade
{
    private double altimetria; //em metros
    private double distancia; //em metros

    public AtivDA() {
        super();
        this.altimetria = 0;
        this.distancia = 0;
    }
    public AtivDA(String descricao, String idAtiv, LocalDate dataRealizacao, int duracao, boolean hard, double FCM, ArrayList<Utilizador> utilizadores, double altimetria, double distancia) {
        super(descricao, idAtiv, dataRealizacao, duracao, hard, FCM, utilizadores);
        this.altimetria = altimetria;
        this.distancia = distancia;
    }
    public AtivDA(AtivDA outro) {
        super(outro);
        this.altimetria = outro.getAltimetria();
        this.distancia = outro.getDistancia();
    }
    
    //get
    public double getAltimetria() {
        return altimetria;
    }
    public double getDistancia() {
        return distancia;
    }

    
    //set
    public void setAltimetria(double altimetria) {
        this.altimetria = altimetria;
    }
    public void setDistancia(double distancia) {
        this.distancia = distancia;
    }

    
    /** método que calcula as calorias gastas */
    @Override
    public double calorias_queimadas(Utilizador u){
        return u.calculaMulCalorias() + this.distancia * 0.2 + this.altimetria * 0.2 + u.calculaIdade(getDataRealizacao()) * 0.2  - 55 / 4;
    }
    
    //metodos
    @Override
    public Atividade clone() {
        return new AtivDA(this);
    }
    @Override
    public String toString() {
        return super.toString()+
                "\nDistância: " + distancia +
                "\nAltimetria: " + altimetria;
    }
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;
        AtivDA ativ = (AtivDA) o;
        return Double.compare(ativ.getDistancia(), getDistancia()) == 0
                && Double.compare(ativ.getAltimetria(), getAltimetria()) == 0;
    }
    
}
