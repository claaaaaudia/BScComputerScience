package Codigo;
import java.util.*; 
import java.io.Serializable;
import java.time.LocalDate;

public class PlanoTreino implements Serializable
{
    private ArrayList<Atividade> atividades;
    private ArrayList<Utilizador> utilizadores;
    
    public PlanoTreino() {
        this.atividades = new ArrayList<Atividade>();
        this.utilizadores = new ArrayList<Utilizador>();
    }
    
    public PlanoTreino(ArrayList<Atividade> atividades, ArrayList<Utilizador> utilizadores) {
        this.atividades = atividades;
        this.utilizadores = utilizadores;
    }
    
    public PlanoTreino(PlanoTreino umPlanoTreino) {
        this.atividades = umPlanoTreino.getAtividades();
        this.utilizadores = umPlanoTreino.getUtilizadores();
    }


    //gets
    public ArrayList<Atividade> getAtividades() {
        return this.atividades;
    }
    public ArrayList<Utilizador> getUtilizadores() {
        return this.utilizadores;
    }
    
    //sets
    public void setAtividades(ArrayList<Atividade> atividades) {
        this.atividades = atividades;
    }
    public void setUtilizadores(ArrayList<Utilizador> utilizadores) {
        this.utilizadores = utilizadores;
    }
    
    //metodos complementares
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        PlanoTreino planoTreino = (PlanoTreino) o;
        return this.atividades.equals(planoTreino.getAtividades()) && 
                this.utilizadores.equals(planoTreino.getUtilizadores());
    }
    @Override
    public String toString() {
        String ret = "Atividades do Plano de Treino: " + "\n\n";
        for (Atividade atividade : this.atividades) {
            ret += atividade.toStringSemUtil() + " \n\n";
        }
        ret += "Utilizadores: ";
        for (Utilizador utilizador : this.utilizadores) {
            ret += utilizador.getNome() + ", ";
        }
        return ret.substring(0, ret.length() - 2);
    }
    
    //verificar se uma atividade esta neste plano de treino
    public boolean checkAtividade(Atividade atividade) {
        for (Atividade tentativa : this.atividades) {
            if (tentativa.equals(atividade)) {
                return true;
            }
        }
        return false;
    }
    
    //adicionar uma atividade ao plano
    public void addAtividade(Atividade atividade) {
        ArrayList<Atividade> lista = getAtividades();
        lista.add(atividade);
        setAtividades(lista);
    }

    //adicionar um utilizador ao plano
    public void addUtilizador(Utilizador utilizador) {
        ArrayList<Utilizador> lista = getUtilizadores();
        lista.add(utilizador);
        setUtilizadores(lista);
    }
    
    public ArrayList<LocalDate> recPT() { //datas diferentes no plano de treino
        ArrayList<LocalDate> datas_diferentes = new ArrayList<LocalDate>();
        for (Atividade a: this.atividades) {
            if (!datas_diferentes.contains(a.getDataRealizacao())) {
                datas_diferentes.add(a.getDataRealizacao());
            }
        }
        return datas_diferentes;
    }

    public ArrayList<String> ativPT() { //tipos de atividade diferentes no plano de treino
        ArrayList<String> ativ_diferentes = new ArrayList<String>();
        for (Atividade a: this.atividades) {
            if (!ativ_diferentes.contains(a.getDescricao())) {
                ativ_diferentes.add(a.getDescricao());
            }
        }
        return ativ_diferentes;
    }

    public int ativMax() { //qual o maximo de atividades por dia no plano de treino
        int max = 0;
        for (LocalDate data: this.recPT()) {
            int n = 0;
            for (Atividade a: this.atividades) {
                if (data.equals(a.getDataRealizacao())) n++;
            }
            if (n > max) max = n;
        }
        return max;
    }

    public boolean maisQueUmHard() {
        boolean b = false;
        int hpd = 0; //hard por dia
        for (LocalDate data: this.recPT()) {
            hpd = 0;
            for (Atividade a: this.atividades) {
                if (data.equals(a.getDataRealizacao()) && a.getHard()) {
                    hpd++;
                }
            }
            if (hpd > 1) b = true;
        }
        return b;
    }
}
