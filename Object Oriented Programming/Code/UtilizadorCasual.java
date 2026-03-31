package Codigo;
import java.util.Map;
import java.time.LocalDate;

public class UtilizadorCasual extends Utilizador
{
    private final double multiplicador;
    
    public UtilizadorCasual(){
        super();
        this.multiplicador = 1.3;
    }
    
    public UtilizadorCasual(String c, String e, String n, String m, Genero g, double f, LocalDate d, double a, double pe, Map<String, Atividade> atividade, double mult){
        super(c, e, n, m, g, f, d, a, pe, atividade);
        this.multiplicador = mult;
    }
    
    public UtilizadorCasual(String c, String e, String n, String m, Genero g, double f, LocalDate d, double a, double pe){
        super(c, e, n, m, g, f, d, a, pe);
        this.multiplicador = 1.3;
    }
    
    public UtilizadorCasual(UtilizadorCasual u){
        super(u);
        this.multiplicador = u.getMultiplicador();
    }
    
    public double getMultiplicador(){
        return this.multiplicador;
    }
    
    public double calculaMulCalorias(){
        return  ( 0.2 * getPeso() ) * this.multiplicador;
    }
    
    @Override
    public boolean equals(Object o){
        if (this == o) return true;
        if (( o == null) || (this.getClass() != o.getClass())) return false;
        UtilizadorCasual u = (UtilizadorCasual) o;
        
        return(super.equals(u) && this.getMultiplicador() == u.getMultiplicador() );
    }
    
    @Override
    public String toString(){
        return super.toString() + "\nTipo de Utilizador: Casual\n" +"Multiplicador: " + this.multiplicador;
    }
    
    @Override
    public Utilizador clone() {
        return new UtilizadorCasual(this);
    }
}
