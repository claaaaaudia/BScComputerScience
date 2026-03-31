package Codigo;
import java.time.LocalDate;
import java.util.ArrayList;
import java.io.Serializable;

abstract class Atividade implements Serializable
{   
    private String descricao;
    private String idAtiv;
    private LocalDate dataRealizacao;
    private int duracao; //em minutos
    private boolean hard;
    private double FCM;
    private ArrayList<Utilizador> utilizadores;
    
    public Atividade() {
        this.descricao = "";
        this.idAtiv = "";
        this.dataRealizacao = LocalDate.EPOCH;
        this.duracao = 0;
        this.hard = false;
        this.FCM = 0;
        this.utilizadores = new ArrayList<>();
    }
    public Atividade(String descricao, String idAtiv, LocalDate dataRealizacao, int duracao, boolean hard, double FCM, ArrayList<Utilizador> utilizadores) {
        this.descricao = descricao;
        this.idAtiv = idAtiv;
        this.dataRealizacao = dataRealizacao;
        this.duracao = duracao;
        this.hard = hard;
        this.FCM = FCM;
        this.utilizadores = utilizadores;
    }
    public Atividade(Atividade umaAtividade) {
        this.descricao = umaAtividade.getDescricao();
        this.idAtiv = umaAtividade.getIdAtiv();
        this.dataRealizacao = umaAtividade.getDataRealizacao();
        this.duracao = umaAtividade.getDuracao();
        this.hard = umaAtividade.getHard();
        this.FCM = umaAtividade.getFCM();
        this.utilizadores = umaAtividade.getUtilizadores();
    }
    
    //gets
    public String getDescricao() {
        return descricao;
    }
    public String getIdAtiv() {
        return idAtiv;
    }
    public LocalDate getDataRealizacao() {
        return dataRealizacao;
    }
    public int getDuracao() {
        return duracao;
    }
    public boolean getHard() {
        return hard;
    }
    public double getFCM() {
        return FCM;
    }
    public ArrayList<Utilizador> getUtilizadores() {
        return utilizadores;
    }
    
    //sets
    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }
    public void setIdAtiv(String idAtiv) {
        this.idAtiv = idAtiv;
    }
    public void setDataRealizacao(LocalDate dataRealizacao) {
        this.dataRealizacao = dataRealizacao;
    }
    public void setDuracao(int duracao) {
        this.duracao = duracao;
    }
    public void setHard(boolean hard) {
        this.hard = hard;
    }
    public void setFCM(double FCM) {
        this.FCM = FCM;
    }
    public void setUtilizadores(ArrayList<Utilizador> utilizadores) {
        this.utilizadores = utilizadores;
    }
    
    //metodos complementares
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Atividade atividade = (Atividade) o;
        return this.duracao == atividade.getDuracao()
                && this.idAtiv.equals(atividade.getIdAtiv())
                && this.descricao.equals(atividade.getDescricao())
                && this.dataRealizacao.equals(atividade.getDataRealizacao())
                && this.hard == atividade.getHard()
                && this.FCM == atividade.getFCM()
                && this.utilizadores.equals(atividade.getUtilizadores());
    }
    @Override
    public String toString() {
        String ret = "ID da Atividade: " + this.idAtiv +
        "\nDescrição: " + this.descricao +
        "\nData de realização: " + this.dataRealizacao +
        "\nDuração: " + this.duracao +
        "\nFrequência Média Cardíaca: " + this.FCM +
        "\nUtilizadores: ";
        for (Utilizador utilizador : this.utilizadores) {
            ret += utilizador.getNome() + ", ";
        }
        return ret.substring(0, ret.length() - 2);
    }

    @Override
    public abstract Atividade clone(); 
    
    // calcula as calorias queimadas nesta atividade
    public abstract double calorias_queimadas(Utilizador u);
    
    //adiciona utilizador aos utilizadores que fazem a atividade
    public void addUtilizador(Utilizador u){
        this.utilizadores.add(u);
    }

    public String toStringSemUtil() {
        String ret = "ID da Atividade: " + this.idAtiv +
        "\nDescrição: " + this.descricao +
        "\nData de realização: " + this.dataRealizacao +
        "\nDuração: " + this.duracao +
        "\nFrequência Média Cardíaca: " + this.FCM;
        return ret;
    }
    
}
