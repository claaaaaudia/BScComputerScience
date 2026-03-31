package Codigo;
import java.util.Map;
import java.time.LocalDate;

public class UtilizadorProfissional extends Utilizador
{
    private final double multiplicador;
    
    /** Construtores */
    public UtilizadorProfissional(){
        super();
        this.multiplicador = 1.5;
    }
    
    public UtilizadorProfissional(String c, String e, String n, String m, Genero g, double f, LocalDate d, double a, double pe, Map<String, Atividade> atividade, double mult){
        super(c, e, n, m, g, f, d, a, pe, atividade);
        this.multiplicador = mult;
    }
    
    public UtilizadorProfissional(String c, String e, String n, String m, Genero g, double f, LocalDate d, double a, double pe){
        super(c, e, n, m, g, f, d, a, pe);
        this.multiplicador = 1.5;
    }
    
    public UtilizadorProfissional(UtilizadorProfissional u){
        super(u);
        this.multiplicador = u.getMultiplicador();
    }
    
    /** Get */
    public double getMultiplicador(){
        return this.multiplicador;
    }
    
    /** Método que calcula o factor multiplicativo a utilizar no cálculo das calorias*/
    public double calculaMulCalorias(){
        return  ( 0.2 * getPeso() ) * this.multiplicador;
    }
    
    /** Métodos complementares*/
    @Override
    public boolean equals(Object o){
        if (this == o) return true;
        if (( o == null) || (this.getClass() != o.getClass())) return false;
        UtilizadorProfissional u = (UtilizadorProfissional) o;
        
        return(super.equals(u) && this.getMultiplicador() == u.getMultiplicador() );
    }
    
    @Override
    public String toString(){
        return super.toString() + "\nTipo de Utilizador: Profissional\n" +"Multiplicador: " + this.multiplicador;
    }
    
    @Override
    public Utilizador clone() {
        return new UtilizadorProfissional(this);
    }
}
