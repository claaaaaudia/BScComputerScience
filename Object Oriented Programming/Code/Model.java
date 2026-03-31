package Codigo;
import java.time.LocalDate;
import java.io.Serializable;
import java.util.Random;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.concurrent.ThreadLocalRandom;
import java.io.FileNotFoundException;
import java.io.IOException;


public class Model implements Serializable
{
    private List<Utilizador> utilizadores;
    private List<Atividade> atividades;
    private List<PlanoTreino> planosTreino;
    
    private Utilizador utilizadorAtual;

    private LocalDate dataAtual;

    
    public Model(){
        this.utilizadores = new ArrayList<>();
        this.atividades = new ArrayList<>();
        this.planosTreino = new ArrayList<>();
        this.dataAtual = LocalDate.now();
    }
    
    public Model(List<Utilizador> u, List<Atividade> a, List<PlanoTreino> pt, LocalDate data){
        this.utilizadores = u;
        this.atividades = a;
        this.planosTreino = pt;
        this.dataAtual = data;
    }
    
    public Model(Model m){
        this(m.getUtilizadores(), m.getAtividades(), m.getPlanosTreino(), m.getDataAtual());
    }
    
    public List<Utilizador> getUtilizadores(){
        return this.utilizadores;
    }
    
    public void setUtilizadores(List<Utilizador> u){
        this.utilizadores = u;        
    }
    
    public List<Atividade> getAtividades(){
        return this.atividades;
    }
    
    public void setAtividades(List<Atividade> a){
        this.atividades = a;
    }
    
    public List<PlanoTreino> getPlanosTreino(){
        return this.planosTreino;
    }
    
    public void setPlanosTreino(List<PlanoTreino> pt){
        this.planosTreino = pt;
    }

    public Utilizador getUtilizadorAtual(){
        return this.utilizadorAtual;
    }

    public void setUtilizadorAtual(Utilizador u){
        this.utilizadorAtual = u;
    }

    public LocalDate getDataAtual(){
        return this.dataAtual;
    }

    public void setDataAtual(LocalDate d){
        this.dataAtual = d;
    }  

    
    public String toString(){
        
        StringBuilder s = new StringBuilder();
        s.append("Utilizadores: ");
        s.append(this.utilizadores);
        s.append("\nAtividades: ");
        s.append(this.atividades);
        s.append("\nPlanos de Treino: ");
        s.append(this.planosTreino);
        s.append("\nUtilizador Atual: ");
        s.append(this.utilizadorAtual);
        s.append("\nData Atual: ");
        s.append(this.dataAtual);

        
        return s.toString();
    }
    
    
    public Model clone(){
        return new Model(this);
    }
    
    public void RegistarUtilizador(String email, String nome, String morada, Genero genero, double FCM, LocalDate aniversario, double altura, double peso, int tipoUtilizador) throws UtilizadorExisteException{
        boolean haUtilizador = utilizadores.stream().anyMatch(utilizador -> utilizador.getEmail().equals(email));
        
        if(haUtilizador){
            throw new UtilizadorExisteException("Já existe um utilizador associado a esse email.");
        }
        
        int quantos = this.utilizadores.size() +1;
        String id = "U" + quantos;
        
        if (tipoUtilizador == 0){
            UtilizadorAmador novo = new UtilizadorAmador(id, email, nome, morada, genero, FCM, aniversario, altura, peso);
            utilizadores.add(novo);
        } else if (tipoUtilizador == 1){
            UtilizadorCasual novo = new UtilizadorCasual(id, email, nome, morada, genero, FCM, aniversario, altura, peso);
            utilizadores.add(novo);
        } else if (tipoUtilizador == 2){
            UtilizadorProfissional novo = new UtilizadorProfissional(id, email, nome, morada, genero, FCM, aniversario, altura, peso);
            utilizadores.add(novo);
        }
    }
    
    public void addQuestao(String pergunta, int resposta, ArrayList<Questao> q){
        q.add(new EscolhaMultipla(pergunta, resposta));
    }
    
    public void addQuestao(String pergunta, String resposta, ArrayList<Questao> q){
        boolean b = false;
        if (resposta.equals("S")) {
            b = true;
        }
        else if (resposta.equals("N")) {
            b = false;
        }
        
        q.add(new VouF(pergunta, b));
    }
    
    public int respostaQuiz(ArrayList<Questao> q){
        Quiz quiz = new Quiz();
        quiz.setQuestoes(q);
        
        int resultado = quiz.takeQuiz();
        return resultado;
    }
    
    public void Login(String email) throws UtilizadorNaoExisteException{
        boolean existe = false;
        
        for(Utilizador u : this.utilizadores){ 
            if(u.getEmail().equals(email)){
                setUtilizadorAtual(u);
                existe = true;
            }
        }
        
        if(!existe){
            throw new UtilizadorNaoExisteException("Não existe um utilizador associado a esse email");
        }
    }
    
    public void RegistarAtividadeDA(String descricao, LocalDate dataRealizacao, int duracao, boolean hard, double FCM, double altimetria, double distancia) {      
        int quantos = this.atividades.size() + 1;
        String id = "A" + quantos;
        
        ArrayList<Utilizador> utilizadores = new ArrayList<Utilizador>();
        
        AtivDA nova_ativ = new AtivDA(descricao, id, dataRealizacao, duracao, hard, FCM, utilizadores, altimetria, distancia);
        nova_ativ.addUtilizador(this.utilizadorAtual);
        this.atividades.add(nova_ativ);
        this.utilizadorAtual.addAtividade(nova_ativ, this.dataAtual);
    }
    
    public void RegistarAtividadeD(String descricao, LocalDate dataRealizacao, int duracao, boolean hard, double FCM, double distancia) {      
        int quantos = this.atividades.size() + 1;
        String id = "A" + quantos;
        
        ArrayList<Utilizador> utilizadores = new ArrayList<Utilizador>();
        
        AtivD nova_ativ = new AtivD(descricao, id, dataRealizacao, duracao, hard, FCM, utilizadores, distancia);
        nova_ativ.addUtilizador(this.utilizadorAtual);
        this.atividades.add(nova_ativ);
        this.utilizadorAtual.addAtividade(nova_ativ, this.dataAtual);
    }
    
    public void RegistarAtividadeRP(String descricao, LocalDate dataRealizacao, int duracao, boolean hard, double FCM, int repeticoes, int intervalo, int peso) {      
        int quantos = this.atividades.size() + 1;
        String id = "A" + quantos;
        
        ArrayList<Utilizador> utilizadores = new ArrayList<Utilizador>();
        
        AtivRP nova_ativ = new AtivRP(descricao, id, dataRealizacao, duracao, hard, FCM, utilizadores, repeticoes, intervalo, peso);
        nova_ativ.addUtilizador(this.utilizadorAtual);
        this.atividades.add(nova_ativ);
        this.utilizadorAtual.addAtividade(nova_ativ, this.dataAtual);
    }
    
    public void RegistarAtividadeR(String descricao, LocalDate dataRealizacao, int duracao, boolean hard, double FCM, int repeticoes, int intervalo) {      
        int quantos = this.atividades.size() + 1;
        String id = "A" + quantos;
        
        ArrayList<Utilizador> utilizadores = new ArrayList<Utilizador>();
                
        AtivR nova_ativ = new AtivR(descricao, id, dataRealizacao, duracao, hard, FCM, utilizadores, repeticoes, intervalo);
        nova_ativ.addUtilizador(this.utilizadorAtual);
        this.atividades.add(nova_ativ);
        this.utilizadorAtual.addAtividade(nova_ativ, this.dataAtual);
    }
    
    public void geraPTnormal(int quantidade, List<String> atividadesEscolhidas){
        
        ArrayList<Atividade> atividadesPT = new ArrayList<Atividade>();
        
        for(String ae: atividadesEscolhidas){
            for(Atividade a: this.atividades){
                if(ae.equals(a.getIdAtiv())){
                    atividadesPT.add(a);
                }
            }
        }
        
        ArrayList<Utilizador> utilizadores = new ArrayList<Utilizador>();
        
        PlanoTreino novo_pt = new PlanoTreino(atividadesPT, utilizadores);
        novo_pt.addUtilizador(this.utilizadorAtual);
        this.planosTreino.add(novo_pt);
        this.utilizadorAtual.addAtividade(novo_pt, this.dataAtual);
    }
    
    public void geraPT(boolean hard, int apd_max, int dif_max, int recorrencia, double calorias) throws AtividadesInsuficientesException{
        //apd_max nunca pode ser maior que 3!

        ArrayList<Atividade> atividades_consideradas = new ArrayList<>();
        for (Atividade a : this.atividades) { //filtrar hard
            if (!hard || a.getHard()) atividades_consideradas.add(a);
        }

        int consumo_calorias;
        int dif;
        int rec;
        int apd;
        boolean mais_que_um_hard;
        ArrayList<Atividade> atividades_escolhidas;
        PlanoTreino plano;

        int conta_tentativas = 0;
        do { //vamos gerar planos de treino ate encontrar um que cumpra os requisitos ou ate esgotar o maximo de tentativas
            conta_tentativas++;
            if(conta_tentativas > 10){
                throw new AtividadesInsuficientesException("Número máximo de tentativas atingido! Verifique se existem atividades suficientes para criar um plano de treino.");
            }

            //vamos la denovo gente
            consumo_calorias = 0;
            atividades_escolhidas = new ArrayList<Atividade>();

            while (consumo_calorias < calorias) { //gera plano de treino aleatorio ate atingir as calorias
                Random random = new Random();
                int randomIndice = random.nextInt(atividades_consideradas.size());
                Atividade randomAtividade = atividades_consideradas.get(randomIndice);

                LocalDate hoje = LocalDate.now(); //vamos alterar a data para algures na proxima semana
                int proxima_semana = ThreadLocalRandom.current().nextInt(1, 8);
                LocalDate nova_data = hoje.plusDays(proxima_semana);
                randomAtividade.setDataRealizacao(nova_data);
 
                atividades_escolhidas.add(randomAtividade);
                consumo_calorias += randomAtividade.calorias_queimadas(this.utilizadorAtual);
            } 

            ArrayList<Utilizador> empty = new ArrayList<>();
            plano = new PlanoTreino(atividades_escolhidas,empty);
            plano.addUtilizador(this.utilizadorAtual);
            dif = plano.ativPT().size(); //quantas atividades diferentes existem no plano de treino
            rec = plano.recPT().size(); //quantas dias diferentes existem no plano de treino
            apd = plano.ativMax(); //numero maximo de atividades por dia
            mais_que_um_hard = plano.maisQueUmHard(); //verifica se o plano contem mais do que um hard por dia

        } while(conta_tentativas<10 || (consumo_calorias<calorias || apd>apd_max || rec!=recorrencia || dif>dif_max || mais_que_um_hard==true));

        this.planosTreino.add(plano); //deu certo
    }

    public void avancoData(LocalDate dataTrocar){
        setDataAtual(dataTrocar);
        for(Atividade a : this.atividades){
            for(Utilizador u : this.utilizadores)
                if (a.getUtilizadores().contains(u)){
                    u.addAtividade(a, this.dataAtual);
                }
        }
        for(PlanoTreino pt : this.planosTreino){
            for(Utilizador u : this.utilizadores)
                if (pt.getUtilizadores().contains(u)){
                    u.addAtividade(pt, this.dataAtual);
                }
        }
    }
    
    public String geraPerfil(){
        String s = utilizadorAtual.toString();
        return s;
    }
    
    
    public String maisCalorias (LocalDate dataInicio, LocalDate dataFim)
    {
        int maior = 0;
        int total;
        String nomeUtilizador = "Nenhum utilizador encontrado";

        for (Utilizador tentativa : this.utilizadores) {
            
            total = 0;
            Map<String, Atividade> atividades = tentativa.getAtividadesEfetuadas();

            for (Map.Entry<String, Atividade> entry : atividades.entrySet()) {

                Atividade atividade = entry.getValue();
                LocalDate dataRealizacao = atividade.getDataRealizacao();

                if (dataRealizacao.isBefore(dataFim) && dataRealizacao.isAfter(dataInicio)) {

                    total += atividade.calorias_queimadas(tentativa);
                    
                }
            }

            if (total > maior) {
                maior = total;
                nomeUtilizador = tentativa.getNome();
            }

        }
        
        return nomeUtilizador;
    }


    public String maisAtividades (LocalDate dataInicio, LocalDate dataFim){
        int maior = 0,total;
        String nomeUtilizador = "Nenhum utilizador encontrado";

        for (Utilizador tentativa : this.utilizadores) {
            
            total = 0;
            Map<String, Atividade> atividades = tentativa.getAtividadesEfetuadas();

            for (Map.Entry<String, Atividade> entry : atividades.entrySet()) {

                Atividade atividade = entry.getValue();
                LocalDate dataRealizacao = atividade.getDataRealizacao();

                if (dataRealizacao.isBefore(dataFim) && dataRealizacao.isAfter(dataInicio)) {

                    total += 1;

                }
            }

            if (total > maior) {
                maior = total;
                nomeUtilizador = tentativa.getNome();
            }

        }
        
        return nomeUtilizador;
    }


    public String maisRealizada() {
        int distancia = 0, altimetria = 0, repeticoes = 0, peso = 0;
        String tipoAtividade = "Nenhuma atividade encontrada";

        for (Utilizador tentativa : this.utilizadores) {
            
            Map<String, Atividade> atividades = tentativa.getAtividadesEfetuadas();

            for (Map.Entry<String, Atividade> entry : atividades.entrySet()) {

                Atividade atividade = entry.getValue();

                if (atividade instanceof AtivD) {
                    distancia++;
                } else if (atividade instanceof AtivDA) {
                    altimetria++;
                } else if (atividade instanceof AtivR) {
                    repeticoes++;
                } else if (atividade instanceof AtivRP) {
                    peso++;
                }


            }

        }

        if (distancia >= altimetria && distancia >= repeticoes && distancia >= peso) {
            tipoAtividade = "Distancia";
        } else if (altimetria >= distancia && altimetria >= repeticoes && altimetria >= peso) {
            tipoAtividade = "Altimetria";
        } else if (repeticoes >= distancia && repeticoes >= altimetria && repeticoes >= peso) {
            tipoAtividade = "Repetições";
        } else if (peso >= distancia && peso >= altimetria && peso >= repeticoes) {
            tipoAtividade = "Peso";
        }          


        return tipoAtividade;
    }


    public double quantosKms (LocalDate dataInicio, LocalDate dataFim, String email) throws UtilizadorNaoExisteException {
        boolean existe = false;
        Map<String, Atividade> atividades = new HashMap<>();
        
        for(Utilizador u : this.utilizadores){ 
            if(u.getEmail().equals(email)){
                atividades = u.getAtividadesEfetuadas();
                existe = true;
            }
        }

        if (existe == false) {
            throw new UtilizadorNaoExisteException("Não existe um utilizador associado a esse email!");
        }

        double total = 0;

        for (Map.Entry<String, Atividade> entry : atividades.entrySet()) {
        
            Atividade atividade = entry.getValue();
            LocalDate dataRealizacao = atividade.getDataRealizacao();

            if (dataRealizacao.isBefore(dataFim) && dataRealizacao.isAfter(dataInicio)) {
                if (atividade instanceof AtivD) {
                    AtivD temp = (AtivD) atividade;
                    total += temp.getDistancia();
                } else if (atividade instanceof AtivDA) {
                    AtivDA temp = (AtivDA) atividade;
                    total += temp.getDistancia();
                }
            }    
        }
        total /=1000; // por em kms
        
        return total;
    }


    public double quantaAltura (LocalDate dataInicio, LocalDate dataFim, String email) throws UtilizadorNaoExisteException {
        boolean existe = false;
        Map<String, Atividade> atividades = new HashMap<>();
        
        for(Utilizador u : this.utilizadores){ 
            if(u.getEmail().equals(email)){
                atividades = u.getAtividadesEfetuadas();
                existe = true;
            }
        }

        if (existe == false) {
            throw new UtilizadorNaoExisteException("Não existe um utilizador associado a esse email!");
        }

        double total = 0;
 
        for (Map.Entry<String, Atividade> entry : atividades.entrySet()) {
        
            Atividade atividade = entry.getValue();
            LocalDate dataRealizacao = atividade.getDataRealizacao();

            if (dataRealizacao.isBefore(dataFim) && dataRealizacao.isAfter(dataInicio)) {
                if (atividade instanceof AtivDA) {
                    AtivDA temp = (AtivDA) atividade;
                    total += temp.getAltimetria();
                }
            }
        }
        total /=1000; // por em kms
        
        return total;
    }

    public PlanoTreino maisExaustivo (){
        int total = 0, maior = 0;
        PlanoTreino planoTreino = new PlanoTreino();
        UtilizadorCasual utilizador = new UtilizadorCasual();

        for (PlanoTreino tentativa : this.planosTreino) {
            total = 0;
            ArrayList<Atividade> atividades = tentativa.getAtividades();
            for (Atividade atividade : atividades) {
                total += atividade.calorias_queimadas(utilizador);
            }
            if (total > maior) {
                maior = total;
                planoTreino = tentativa;
            }
        }

        return planoTreino;
    }
    
    public String listaAtivs(String email) throws UtilizadorNaoExisteException
    {
        boolean existe = false;
        Map<String, Atividade> atividades = new HashMap<>();
        
        for(Utilizador u : this.utilizadores){ 
            if(u.getEmail().equals(email)){
                atividades = u.getAtividadesEfetuadas();
                existe = true;
            }
        }
        
        if(!existe){
            throw new UtilizadorNaoExisteException("Não existe um utilizador associado a esse email");
        }
        
        String ret = "Atividades do utilizador:\n\n";
        for (Map.Entry<String, Atividade> entry : atividades.entrySet()) {
            Atividade atividade = entry.getValue();
            ret+=atividade.toStringSemUtil() + "\n\n";
        }

        return ret;
    }
    
    public void salvaEstado(String ficheiro) throws FileNotFoundException, IOException{
        FileOutputStream fos = new FileOutputStream(ficheiro);
        ObjectOutputStream oos = new ObjectOutputStream(fos);
        
        oos.writeObject(this);
        
        oos.flush();
        oos.close();
    }
    
    public static Model carregaEstado(String ficheiro) throws FileNotFoundException, IOException, ClassNotFoundException{
        FileInputStream fis = new FileInputStream(ficheiro);
        ObjectInputStream ois = new ObjectInputStream(fis);

        // ler a instância de Model que foi gravada
        Model newModel = (Model) ois.readObject();
        
        return newModel;
    }
}