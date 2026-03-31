package Codigo;
import java.util.Scanner;
import java.time.LocalDate;
import java.time.DateTimeException;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;

public class TextUI
{
    private Model model;
    private Scanner sc;
    
    /**
    * Construtor que cria os menus e o model
    */
    
    public TextUI() {
        this.model = new Model();
        sc = new Scanner(System.in);
    }
    
   
    /**
    * Método que executa o menu principal.
    * Coloca a interface em execução.
    */
    
    public void main(){
        String[] op = {"Login", "Registar", "Carregar"};
        
        NewMenu menu = new NewMenu(op);
        
        //se não tiver usuários registados fazer pre-condition para login não aparecer
        menu.setPreCondition(1, () -> this.model.getUtilizadores().size()>0);
        menu.setHandler(1,() -> Login());
        menu.setHandler(2,() -> registoUtilizador());
        menu.setHandler(3, () -> Carregar());
                
        menu.run();
    }
    
    public void Login(){
        
        System.out.println("Insira o Email: ");
        String email = sc.nextLine();
        
        try{
            this.model.Login(email);
            System.out.println("Login efetuado!");
            menuInicial();
        } catch(UtilizadorNaoExisteException e){
            System.out.println("Erro ao efetuar o login: " + e.getMessage());
        }
        
    }
    
    public void registoUtilizador(){
        //menu de registo de utilizador com os sets e o quiz 
        
        ArrayList<Questao> q = new ArrayList<Questao>();
        
        String umS = "Faço exercício todos os dias. (S/N)";
        System.out.println(umS);
        String um = sc.nextLine();
        this.model.addQuestao(umS, um, q);
        String doisS = "Gosto de fazer exercício. (S/N)";
        System.out.println(doisS);
        String dois = sc.nextLine();
        this.model.addQuestao(doisS, dois, q);
        String tresS = "Mantenho um equilibrio entre atividade física e descanso adequado. \n1-Nunca\n2-Raramente\n3-Às Vezes\n4-Muitas Vezes\n5-Sempre";
        System.out.println(tresS);
        int tres = sc.nextInt();
        sc.nextLine();
        this.model.addQuestao(tresS, tres, q);
        String quatroS = "Acredito que exercício físico é eficaz para reduzir o stress e melhorar o humor. (S/N)";
        System.out.println(quatroS);
        String quatro = sc.nextLine();
        this.model.addQuestao(quatroS, quatro, q);
        String cincoS = "Procuro orientação profissional para garantir que os meus exercícios são seguros e eficazes. \n1-Nunca\n2-Raramente\n3-Às Vezes\n4-Muitas Vezes\n5-Sempre";
        System.out.println(cincoS);
        int cinco = sc.nextInt();
        sc.nextLine();
        this.model.addQuestao(cincoS, cinco, q);
        
        int resultado = this.model.respostaQuiz(q);
                
        System.out.println("Email: ");
        String email = sc.nextLine();
        System.out.println("\nNome: ");
        String nome = sc.nextLine();
        System.out.println("\nMorada: ");
        String morada = sc.nextLine();
        System.out.println("\nGenero (Feminino/Masculino/Outro): ");
        Genero genero = obterGenero(sc);
        System.out.println("\nFrequência Cardíaca Média: ");
        Double FCM = sc.nextDouble();
        sc.nextLine();
        System.out.println("\nAno de Nascimento: ");
        int ano = sc.nextInt();
        sc.nextLine();
        System.out.println("\nMês de Nascimento: ");
        int mes = sc.nextInt();
        sc.nextLine();
        System.out.println("\nDia de Nascimento: ");
        int dia = sc.nextInt();
        sc.nextLine();
        System.out.println("\nAltura: ");
        double altura = sc.nextDouble();
        sc.nextLine();
        System.out.println("\nPeso (kg): ");
        double peso = sc.nextDouble();
        sc.nextLine();
                
        try{
            LocalDate aniversario = LocalDate.of(ano, mes, dia);
            this.model.RegistarUtilizador(email, nome, morada, genero, FCM, aniversario, altura, peso, resultado);
        } catch(UtilizadorExisteException e){
            System.out.println("Erro ao efetuar o registo: " + e.getMessage());
        } catch(DateTimeException e) {
            System.out.println("Não foi possível mudar a data: " + e.getMessage());
        }
    } 
    
    
    public Genero obterGenero(Scanner sc){
        Genero genero;
        
        do{
            switch(sc.nextLine()){
                case "Feminino":
                    genero = Genero.Feminino;
                    break;
                case "Masculino":
                    genero = Genero.Masculino;
                    break;
                case "Outro":
                    genero = Genero.Outro;
                    break;
                default:
                    genero = null;
            }
        } while(genero == null);
        
        return genero;
    }
    
    public void menuInicial() {
        
        String[] op = {"Perfil de Usuário",
                        "Planos de treino", 
                        "Atividades", 
                        "Utilizadores",
                        "Estatísticas",
                        "Definições"};
                        
        NewMenu menuInicial = new NewMenu(op);
                
        menuInicial.setHandler(1,() -> perfil());
        menuInicial.setHandler(2,() -> planoTreino());
        menuInicial.setHandler(3,() -> atividade());
        menuInicial.setPreCondition(4, () -> this.model.getUtilizadores().size()>0);
        menuInicial.setHandler(4,() -> utilizadores());
        menuInicial.setHandler(5,() -> estatistica());
        menuInicial.setHandler(6,() -> definicoes());
        
        menuInicial.run();
    }
    
    public void estatistica() {

        String[] op = {"Utilizador que dispensou mais calorias", //data
                        "Utilizador que realizou mais atividades", //data
                        "Tipo de atividade mais realizada",
                        "Quantidade de kms que um utilizador realizou", //data
                        "Quantos metros de altimetria que um utilizador realizou", //data
                        "Plano de treino mais exigente",
                        "Atividades de um utilizador"};
        
        NewMenu menuEst = new NewMenu(op);
        
        menuEst.setPreCondition(1,() -> this.model.getUtilizadores().size()>0);
        menuEst.setHandler(1,() -> dataInicio(1));
        menuEst.setPreCondition(2,() -> this.model.getUtilizadores().size()>0);
        menuEst.setHandler(2,() -> dataInicio(2));
        menuEst.setPreCondition(3,() -> this.model.getAtividades().size()>0);
        menuEst.setHandler(3,() -> maisRealizada());
        menuEst.setHandler(4,() -> dataInicio(3));
        menuEst.setHandler(5,() -> dataInicio(4));
        menuEst.setPreCondition(6,() -> this.model.getPlanosTreino().size()>0);
        menuEst.setHandler(6,() -> maisExaustivo());
        menuEst.setPreCondition(7,() -> this.model.getAtividades().size()>0);
        menuEst.setHandler(7,() -> listaAtivs());
        
        menuEst.run();
    }
    
    public void maisRealizada(){
        String r = this.model.maisRealizada();
        System.out.println(r);
    }
    
    public void maisExaustivo(){
        PlanoTreino r = this.model.maisExaustivo();
        System.out.println(r);
    }
    
    public void listaAtivs(){
        System.out.println("Digite o email do utilizador de que deseja saber: \n");
        String email = sc.nextLine();
        try{
            String atividades = this.model.listaAtivs(email);
            
            System.out.println(atividades);

        } catch (UtilizadorNaoExisteException e){
            System.out.println("Erro ao procurar: " + e.getMessage());            
        }
    }
    
    public void dataInicio (int qual) {
        
        String[] op = {"Estatistica desde Sempre",
                        "Estatistica em um período especifico"};

        NewMenu menu = new NewMenu(op);
        
        LocalDate inicio = LocalDate.EPOCH;
        LocalDate fim = this.model.getDataAtual();

        if (qual == 1) {
            menu.setHandler(1,()-> maisCaloria(inicio,fim));
        } else if (qual == 2) {
            menu.setHandler(1,()-> maisAtividade(inicio,fim));
        } else if (qual == 3) {
            menu.setHandler(1,() -> quantosKm(inicio,fim));
        } else if (qual == 4) {
            menu.setHandler(1,() -> quantaAlt(inicio,fim));
        }
        
        menu.setHandler(2, ()->escolherData(qual));
        
        menu.run();
    }
    
    public void maisCaloria(LocalDate inicio,LocalDate fim){
        String quem = this.model.maisCalorias(inicio,fim);
        System.out.println(quem);
    }
    
    public void maisAtividade(LocalDate inicio,LocalDate fim){
        String quem = this.model.maisAtividades(inicio,fim);
        System.out.println(quem);
    }
    
    public void quantosKm(LocalDate inicio,LocalDate fim){
        System.out.println("Digite o email do utilizador de que deseja saber: \n");
        String email = sc.nextLine();
        
        try{
            double r = this.model.quantosKms(inicio, fim, email);
            System.out.println(r + " kms");
        } catch(UtilizadorNaoExisteException e){
            System.out.println("Não foi possível procurar: " + e.getMessage());
        }
    }
    
    public void quantaAlt(LocalDate inicio,LocalDate fim){
        System.out.println("Digite o email do utilizador de que deseja saber: \n");
        String email = sc.nextLine();
        try{
            double r = this.model.quantaAltura(inicio, fim, email);
            System.out.println(r + " kms");
        } catch(UtilizadorNaoExisteException e){
            System.out.println("Não foi possível procurar: " + e.getMessage());
        }
    }
    
    public void escolherData(int qual) {
        try{
            System.out.println("Data de ínicio:");
            System.out.println("\nAno: ");
            int ano = sc.nextInt();
            sc.nextLine();
            System.out.println("\nMês: ");
            int mes = sc.nextInt();
            sc.nextLine();
            System.out.println("\nDia: ");
            int dia = sc.nextInt();
            sc.nextLine();
            LocalDate inicio = LocalDate.of(ano, mes, dia);
            System.out.println("\nData de fim:");
            System.out.println("\nAno: ");
            ano = sc.nextInt();
            sc.nextLine();
            System.out.println("\nMês: ");
            mes = sc.nextInt();
            sc.nextLine();
            System.out.println("\nDia: ");
            dia = sc.nextInt();
            sc.nextLine();
            LocalDate fim = LocalDate.of(ano, mes, dia);
    
            if (qual == 1) {
                maisCaloria(inicio,fim);
            } else if (qual == 2) {
                maisAtividade(inicio,fim);
            } else if (qual == 3) {
                quantosKm(inicio, fim);
            } else if (qual == 4) {
                quantaAlt(inicio, fim);
            }
            
        } catch (DateTimeException e) {
            System.out.println("Não foi possível procurar: " + e.getMessage());
        }
    }
    
    
    public void utilizadores(){
        for(Utilizador u : this.model.getUtilizadores()){
            System.out.println(u.toString());
            System.out.println("\n"); 
        }
    }
    
    public void perfil(){
        String perfil = this.model.geraPerfil();
        System.out.println(perfil);
    }
    
    public void planoTreino(){
        
        String[] op = {"Criar plano de treino novo", "Gerar plano de treino automático", "Ver planos de treino"};
        
        NewMenu menuPT = new NewMenu(op);
        
        menuPT.setHandler(1, () -> CriaPlanoTreino());
        menuPT.setHandler(2, () -> CriarPlanoTreinoAuto());
        menuPT.setPreCondition(3, () -> this.model.getPlanosTreino().size()>0);
        menuPT.setHandler(3, () -> VerPlanosTreino());
        
        menuPT.run();
    }
    
    public void CriaPlanoTreino(){
        System.out.println("Criação do Plano de Treino");
        System.out.println("\nQuantas atividades pretende colocar?");
        int quantas = sc.nextInt();
        sc.nextLine();
        int i = 1;
        ArrayList<String> atividades = new ArrayList<String>();
        System.out.println("Atividades Disponíveis");
        
        for(Atividade a : model.getAtividades()){
            System.out.println(i + "-" + a.getDescricao() + " (id: " + a.getIdAtiv() + ")\n");
            i++;
        }
        
        for(int j = quantas; j>0; j--){
            System.out.println("Escreva o ID das atividades que pertende adicionar. " + j + " atividades restantes.");
            String atividade = sc.nextLine();
            atividades.add(atividade);
        }
        
        this.model.geraPTnormal(quantas, atividades);
    }

    public void CriarPlanoTreinoAuto(){
        System.out.println("Criação do Plano de Treino Automático\n");
        System.out.println("Atividade Hard? (S/N)");
        String h = sc.nextLine();
        boolean hard = false;
        if (h.equals("S")) {
            hard = true;
        }
        else if (h.equals("N")) {
            hard = false;
        }
        System.out.println("Número maximo de atividades por dia (De 1 a 3)");
        int max = sc.nextInt();
        sc.nextLine();
        System.out.println("Número maximo de atividades distintas");
        int maxdistintas = sc.nextInt();
        sc.nextLine();
        System.out.println("Recorrência semanal");
        int semanal = sc.nextInt();
        sc.nextLine();
        System.out.println("Consumo calórico mínimo pertendido");
        double caloria = sc.nextDouble(); 
        sc.nextLine();
        
        try{
            this.model.geraPT(hard, max, maxdistintas, semanal, caloria);
        } catch(AtividadesInsuficientesException e){
            System.out.println("Não foi possível criar um plano de treino: " + e.getMessage());
        }
    }
    
    public void VerPlanosTreino(){
        for(PlanoTreino pt : this.model.getPlanosTreino()){
            System.out.println(pt.toString());
            System.out.println("\n"); 
        }
    }
    
    public void atividade(){
        
        String[] op = {"Criar atividade nova", "Ver atividades"};
        
        NewMenu menuAtiv = new NewMenu(op);
        
        menuAtiv.setHandler(1, () -> RegistarAtividade());
        menuAtiv.setPreCondition(2, () -> this.model.getAtividades().size()>0);
        menuAtiv.setHandler(2, () -> VerAtividades()); 
        
        menuAtiv.run();
    }
    
    public void RegistarAtividade(){
        
        String[] op = {"Atividade com Distância", "Atividade com Distância e Altimetria", "Atividade com Repetições", "Atividade com Repetições e Peso"};
        
        NewMenu m = new NewMenu(op);
        
        m.setHandler(1, () -> AtivDist());
        m.setHandler(2, () -> AtivDistAlt());
        m.setHandler(3, () -> AtivRep());
        m.setHandler(4, () -> AtivRepPeso());
        
        m.run();
    }
    
    public void AtivDist(){
        System.out.println("Escreva o nome da atividade.");
        String descricao = sc.nextLine(); 
        System.out.println("\nAno de Realização: ");
        int ano = sc.nextInt();
        sc.nextLine();
        System.out.println("\nMês de Realização: ");
        int mes = sc.nextInt();
        sc.nextLine();
        System.out.println("\nDia de Realização: ");
        int dia = sc.nextInt();
        sc.nextLine();
        System.out.println("Duração da atividade (em minutos).");
        int duracao = sc.nextInt();
        sc.nextLine();
        System.out.println("A atividade é considerada Hard? Responda apenas com S ou N.");
        String h = sc.next();
        boolean hard = false;
        if (h.equals("S")) {
            hard = true;
        }
        else if (h.equals("N")) {
            hard= false;
        }
        System.out.println("Qual a sua frequência média cardíaca a realizar esta atividade?");
        double FCM = sc.nextDouble();
        sc.nextLine();
        System.out.println("Distância percorrida na atividade (em metros).");
        double distancia = sc.nextDouble();
        sc.nextLine();
        
        LocalDate dataRealizacao = LocalDate.of(ano, mes, dia);
        
        this.model.RegistarAtividadeD(descricao, dataRealizacao, duracao, hard, FCM, distancia);

    }
    
    public void AtivDistAlt(){
        System.out.println("Escreva o nome da atividade.");
        String descricao = sc.nextLine(); 
        System.out.println("\nAno de Realização: ");
        int ano = sc.nextInt();
        sc.nextLine();
        System.out.println("\nMês de Realização: ");
        int mes = sc.nextInt();
        sc.nextLine();
        System.out.println("\nDia de Realização: ");
        int dia = sc.nextInt();
        sc.nextLine();
        System.out.println("Duração da atividade (em minutos).");
        int duracao = sc.nextInt();
        sc.nextLine();
        System.out.println("A atividade é considerada Hard? Responda apenas com S ou N.");
        String h = sc.next();
        boolean hard = false;
        if (h.equals("S")) {
            hard = true;
        }
        else if (h.equals("N")) {
            hard= false;
        }
        System.out.println("Qual a sua frequência média cardíaca a realizar esta atividade?");
        double FCM = sc.nextDouble();
        sc.nextLine();
        System.out.println("Altimetria da atividade (em metros).");
        double altimetria = sc.nextDouble();
        sc.nextLine();
        System.out.println("Distância percorrida na atividade (em metros).");
        double distancia = sc.nextDouble();
        sc.nextLine();
        
        LocalDate dataRealizacao = LocalDate.of(ano, mes, dia);
        
        this.model.RegistarAtividadeDA(descricao, dataRealizacao, duracao, hard, FCM, altimetria, distancia);

    }
    
    public void AtivRep(){
        System.out.println("Escreva o nome da atividade.");
        String descricao = sc.nextLine(); 
        System.out.println("\nAno de Realização: ");
        int ano = sc.nextInt();
        sc.nextLine();
        System.out.println("\nMês de Realização: ");
        int mes = sc.nextInt();
        sc.nextLine();
        System.out.println("\nDia de Realização: ");
        int dia = sc.nextInt();
        sc.nextLine();
        System.out.println("Duração da atividade (em minutos).");
        int duracao = sc.nextInt();
        sc.nextLine();
        System.out.println("A atividade é considerada Hard? Responda apenas com S ou N.");
        String h = sc.next();
        boolean hard = false;
        if (h.equals("S")) {
            hard = true;
        }
        else if (h.equals("N")) {
            hard= false;
        }
        System.out.println("Qual a sua frequência média cardíaca a realizar esta atividade?");
        double FCM = sc.nextDouble();
        sc.nextLine();
        System.out.println("Número de Repetições.");
        int rep = sc.nextInt();
        sc.nextLine();
        System.out.println("Intervalo entre as repetições.");
        int intervalo = sc.nextInt();
        sc.nextLine();
        
        LocalDate dataRealizacao = LocalDate.of(ano, mes, dia);
        
        this.model.RegistarAtividadeR(descricao, dataRealizacao, duracao, hard, FCM, rep, intervalo);
    }
    
    public void AtivRepPeso(){
        System.out.println("Escreva o nome da atividade.");
        String descricao = sc.nextLine(); 
        System.out.println("\nAno de Realização: ");
        int ano = sc.nextInt();
        sc.nextLine();
        System.out.println("\nMês de Realização: ");
        int mes = sc.nextInt();
        sc.nextLine();
        System.out.println("\nDia de Realização: ");
        int dia = sc.nextInt();
        sc.nextLine();
        System.out.println("Duração da atividade (em minutos).");
        int duracao = sc.nextInt();
        sc.nextLine();
        System.out.println("A atividade é considerada Hard? Responda apenas com S ou N.");
        String h = sc.next();
        boolean hard = false;
        if (h.equals("S")) {
            hard = true;
        }
        else if (h.equals("N")) {
            hard= false;
        }
        System.out.println("Qual a sua frequência média cardíaca a realizar esta atividade?");
        double FCM = sc.nextDouble();
        sc.nextLine();
        System.out.println("Número de Repetições.");
        int rep = sc.nextInt();
        sc.nextLine();
        System.out.println("Intervalo entre as repetições.");
        int intervalo = sc.nextInt();
        sc.nextLine();
        System.out.println("Peso adicionado(em kg).");
        int peso = sc.nextInt();
        sc.nextLine();
        
        LocalDate dataRealizacao = LocalDate.of(ano, mes, dia);
        
        this.model.RegistarAtividadeRP(descricao, dataRealizacao, duracao, hard, FCM, rep, intervalo, peso);
    }
    
    public void VerAtividades(){
        for(Atividade a : model.getAtividades()){
            System.out.println(a.toString());
            System.out.println("\n");
        }
    }
    
    public void definicoes(){
        
        String[] op = {"Ver data atual","Avançar no tempo", "Salvar"};
        
        NewMenu menuDef = new NewMenu(op);

        menuDef.setHandler(1, () -> dizDataAtual());
        menuDef.setHandler(2, () -> avancoData());
        menuDef.setHandler(3, () -> fazerSalvaguarda());
        
        menuDef.run();
    }

    public void dizDataAtual() {
        System.out.println("\nA data atual é: " + this.model.getDataAtual());
    }

    public void avancoData(){
        System.out.println("\nA data atual é: " + this.model.getDataAtual());
        
        try{
            System.out.println("Escolha o ano:");
            int ano = sc.nextInt();
            sc.nextLine();

            System.out.println("Escolha o mês:");
            int mes = sc.nextInt();
            sc.nextLine();

            System.out.println("Escolha o dia:");
            int dia = sc.nextInt();
            sc.nextLine();
            

            LocalDate dataTrocar = LocalDate.of(ano, mes, dia);

            this.model.avancoData(dataTrocar);

        } catch (DateTimeException e) {
            System.out.println("Não foi possível mudar a data: " + e.getMessage());
        }
    }
    
    public void fazerSalvaguarda(){
        String ficheiro = "Codigo/Salva";

        try{
            this.model.salvaEstado(ficheiro);
        } catch(FileNotFoundException e){
            System.out.println("Não foi possível salvar o ficheiro: " + e.getMessage());
        } catch(IOException ie){
            System.out.println("Não foi possível salvar o ficheiro: " + ie.getMessage());            
        }
    }
    
    public void Carregar(){
        String ficheiro = "Codigo/Salva";
        
        try{
            this.model = Model.carregaEstado(ficheiro);
        } catch(FileNotFoundException e){
            System.out.println("Não foi possível carregar o ficheiro: " + e.getMessage());
        } catch(IOException ie){
            System.out.println("Não foi possível carregar o ficheiro: " + ie.getMessage());            
        } catch(ClassNotFoundException ce){
            System.out.println("Não foi possível carregar o ficheiro: " + ce.getMessage());
        }
    }
}
