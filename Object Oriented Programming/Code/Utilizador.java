package Codigo;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;
import java.time.LocalDate;
import java.time.Period;
import java.io.Serializable;


public abstract class Utilizador implements Serializable
{
    private String idUser;
    private String email;
    private String nome;
    private String morada;
    private Genero genero;
    private double FCM; //frequencia cardiaca média
    private LocalDate aniversario;
    private double altura;
    private double peso;
    private Map<String, Atividade> atividadesEfetuadas;
    
    
    /** Construtor por omissão */
    public Utilizador(){
        this.idUser = "";
        this.email = "";
        this.nome = "";
        this.morada = "";
        this.genero = Genero.Outro;
        this.FCM = 0;
        this.aniversario = LocalDate.EPOCH; //EPOCH é a data definida como og nos pcs ou algo assim, 1 de janeiro de 1970 eu acho
        this.altura = 0;
        this.peso = 0;
        this.atividadesEfetuadas = new HashMap<>();
    }
    
    /** Construtor parametrizado */
    public Utilizador(String c, String e, String n, String m, Genero g, double f, LocalDate d, double a, double pe, Map<String, Atividade> atividade){
        this.idUser = c;
        this.email = e;
        this.nome = n;
        this.morada = m;
        this.genero = g;
        this.FCM = f;
        this.aniversario = d;
        this.altura = a;
        this.peso = pe;
        this.atividadesEfetuadas = atividade;
    }
    
    public Utilizador(String c, String e, String n, String m, Genero g, double f, LocalDate d, double a, double pe){
        this.idUser = c;
        this.email = e;
        this.nome = n;
        this.morada = m;
        this.genero = g;
        this.FCM = f;
        this.aniversario = d;
        this.altura = a;
        this.peso = pe;
        this.atividadesEfetuadas = new HashMap<>();
    }
    
    /** Construtor de cópia */
    
    public Utilizador(Utilizador u){
        this.idUser = u.getCodigo();
        this.email = u.getEmail();
        this.nome = u.getNome();
        this.morada = u.getMorada();
        this.genero = u.getGenero();
        this.FCM = u.getFCM();
        this.aniversario = u.getAniversario();
        this.altura = u.getAltura();
        this.peso = u.getPeso();
        this.atividadesEfetuadas = u.getAtividadesEfetuadas();
    }
    
    /** gets e sets */
    
    public String getCodigo(){
        return this.idUser;        
    }
    
    public void setCodigo(String codigo){
        this.idUser = codigo;
    }
    
    public String getEmail(){
        return this.email;
    }
    
    public void setEmail(String email){
        this.email = email;
    }
        
    public String getNome(){
        return this.nome;
    }
    
    public void setNome(String nome){
        this.nome = nome;
    }    
    
    public String getMorada(){
        return this.morada;
    }
    
    public void setMorada(String morada){
        this.morada = morada;
    }
    
    public Genero getGenero(){
        return this.genero;
    }
    
    public void setGenero(Genero genero){
        this.genero = genero;
    }
    
    public double getFCM(){
        return this.FCM;
    }
    
    public void setFCM(double frequencia){
        this.FCM = frequencia;
    }
    
    public LocalDate getAniversario(){
        return this.aniversario;
    }
    
    public void setAniversario(LocalDate data){
        this.aniversario = data;
    }
    
    public double getAltura(){
        return this.altura;
    }
    
    public void setAltura(double altura){
        this.altura = altura;
    }
    
    public double getPeso(){
        return this.peso;
    }
    
    public void setPeso(double peso){
        this.peso = peso;
    }
    
    public Map<String, Atividade> getAtividadesEfetuadas(){
        return atividadesEfetuadas.entrySet().stream().collect(Collectors.toMap(k->k.getKey(), v-> v.getValue().clone()));
    }
    
    public void setAtividadesEfetuadas(Map<String, Atividade> a){
        this.atividadesEfetuadas =  a.entrySet().stream().collect(Collectors.toMap(k->k.getKey(), v-> v.getValue().clone()));
    }
    
    public void addAtividade (Atividade a, LocalDate dataAtual){
        LocalDate dataRealizacao = a.getDataRealizacao();
        
        if(dataAtual.isAfter(dataRealizacao)){
            this.atividadesEfetuadas.put(a.getIdAtiv(), a.clone());
        }
    }
    
    public void addAtividade (PlanoTreino p, LocalDate dataAtual) {
        
        for(Atividade a: p.getAtividades()){
            addAtividade(a, dataAtual);
        }
    }
    
    
    public int calculaIdade(LocalDate dataAtual){
        Period tempo = Period.between(this.aniversario, dataAtual);
        return tempo.getYears();
    }
    
    public abstract double calculaMulCalorias();
   
    /** métodos complementares */
    @Override
    public boolean equals(Object o){
        if (this == o) return true;
        if (( o == null) || (this.getClass() != o.getClass())) return false;
        Utilizador u = (Utilizador) o;
        return Objects.equals(this.idUser, u.getCodigo())
                && Objects.equals(getPeso(), u.getEmail())
                && Objects.equals(getNome(), u.getNome())
                && Objects.equals(this.morada, u.getMorada())
                && getGenero() == u.getGenero()
                && Double.compare(getFCM(), u.getFCM()) == 0
                && Objects.equals(getAniversario(), u.getAniversario())
                && Double.compare(getAltura(), u.getAltura()) == 0
                && Double.compare(getPeso(), u.getPeso()) == 0
                && this.atividadesEfetuadas.equals(u.getAtividadesEfetuadas());
    }
    
    @Override
    public String toString(){
        String ret = "\nID de utilizador: "+ this.idUser +
        "\nEmail: " + this.email +
        "\nNome: " + this.nome +
        "\nMorada: " + this.morada +
        "\nGénero: " + this.genero +
        "\nFrequencia Cardíaca Média: " + this.FCM +
        "\nData de Nascimento: " + this.aniversario +
        "\nAltura: " + this.altura +
        "\nPeso: " + this.peso +
        "\nAtividades: ";
        for (Map.Entry<String, Atividade> entry : this.atividadesEfetuadas.entrySet()) {
        
            Atividade atividade = entry.getValue();
            ret += atividade.getDescricao() + ", ";
        }
        return ret.substring(0, ret.length() - 2);
    }
    
    @Override 
    public abstract Utilizador clone();
}
