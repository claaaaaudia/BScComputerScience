package Codigo;
import java.util.Map;
import java.time.LocalDate;

public class UtilizadorAmador extends Utilizador
{
    private final double multiplicador;
    
    public UtilizadorAmador(){
        super();
        this.multiplicador = 1.1;
    }
    
    public UtilizadorAmador(String c, String e, String n, String m, Genero g, double f, LocalDate d, double a, double pe, Map<String, Atividade> atividade, double mult){
        super(c, e, n, m, g, f, d, a, pe, atividade);
        this.multiplicador = mult;
    }
    
    public UtilizadorAmador(String c, String e, String n, String m, Genero g, double f, LocalDate d, double a, double pe){
        super(c, e, n, m, g, f, d, a, pe);
        this.multiplicador = 1.1;
    }
    
    public UtilizadorAmador(UtilizadorAmador u){
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
        UtilizadorAmador u = (UtilizadorAmador) o;
        
        return(super.equals(u) && this.getMultiplicador() == u.getMultiplicador() );
    }
    
    @Override
    public String toString(){
        return super.toString() + "\nTipo de Utilizador: Amador\n" +"Multiplicador: " + this.multiplicador;
    }
    
    @Override
    public Utilizador clone() {
        return new UtilizadorAmador(this);
    }
}
