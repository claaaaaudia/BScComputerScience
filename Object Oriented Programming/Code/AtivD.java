package Codigo;
import java.time.LocalDate;
import java.util.ArrayList;

public class AtivD extends Atividade
{
    private double distancia; //em metros
    
    public AtivD() {
        super();
        this.distancia = 0;
    }
    public AtivD(String descricao, String idAtiv, LocalDate dataRealizacao, int duracao, boolean hard, double FCM, ArrayList<Utilizador> utilizadores, double distancia) {
        super(descricao, idAtiv, dataRealizacao, duracao, hard, FCM, utilizadores);
        this.distancia = distancia;
    }
    public AtivD(AtivD outro) {
        super(outro);
        this.distancia = outro.getDistancia();
    }
    
    //get
    public double getDistancia() {
        return distancia;
    }
    
    //set
    public void setDistancia(double distancia) {
        this.distancia = distancia;
    }
    
    /** método que calcula as calorias gastas */
    @Override
    public double calorias_queimadas(Utilizador u){
        return u.calculaMulCalorias() + this.distancia * 0.2 + u.calculaIdade(getDataRealizacao()) * 0.2 - 55 / 4;
    }
    
    //metodos
    @Override
    public Atividade clone() {
        return new AtivD(this);
    }
    @Override
    public String toString() {
        return super.toString() +
                "\nDistância: " + this.distancia;
    }
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;
        AtivD ativ = (AtivD) o;
        return Double.compare(ativ.getDistancia(), getDistancia()) == 0;
    }
}
