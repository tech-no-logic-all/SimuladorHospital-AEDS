public enum EstadoJogo {
    MENU_PRINCIPAL,
    SIMULACAO_MAPA,
    TELA_TRIAGEM,
    PAUSA,
    FINALIZANDO
}

float tempoEntreAtualizacoes = 3.0;

public class SimuladorHospital {

    private Grid grid;
    private GeradorTempo geradorTempo;
    private ListaPacientes listaPacientes;
    private GerenciadorMovimento gerenciadorMovimento;

    private boolean inicializado = false;
    private int contadorPacientes = 0;
    private float proximoSpawn = 0;
    private float tempoAtualizarSimulacao = 0;

    private Enfermeira[] enfermeiras;
    private Medico[] medicos;

    private boolean relogioIniciado = false;
    private boolean pausado = false;

    private float tempoSimulacao = 0;
    private int ultimoMillisReal = 0;


    public SimuladorHospital() {
        grid = new Grid();
        geradorTempo = new GeradorTempo();
        listaPacientes = new ListaPacientes();
        this.proximoSpawn = 0;
        this.contadorPacientes = 0;
        this.inicializado = false;
    }

    public void setup() {
        grid.inicializarImagens();
    }

    //esse iniciarGrid acho q tem que receber uma string pro caminho do arquivo do mapa .txt
    public void iniciarGrid (Grid grid) {

        if (!inicializado) {

            try {
                //vai ser chamado sempre que um mapa diferente for escolhido, para resetar o grid e desenhar o novo mapa
                grid.inicializarGrid("data/mapa1.txt");
                gerenciadorMovimento = new GerenciadorMovimento(grid.getMapaChar());
                inicializado = true;

                this.enfermeiras = grid.getEnfermeiras();
                this.medicos = grid.getMedicos();

            } catch (MapaNaoFormatadoException e) {
                println(e.getMessage());
                return;
            }   
        }
        grid.desenharGrid();
    }

    //chamado quando o botão de iniciar simulação for clicado
    public void iniciarSimulacao() {

        if (!inicializado) {
            println("Não é possível iniciar antes de carregar o grid.");
            return;
        }

        tempoSimulacao = 0;

        // Define o instante real usado como referência.
        ultimoMillisReal = millis();

        // Primeira atualização pode acontecer imediatamente.
        tempoAtualizarSimulacao = 0;

        // Agenda o primeiro paciente usando o tempo lógico.
        proximoSpawn = tempoSimulacao + geradorTempo.gerarTempoSpawn();

        relogioIniciado = true;
        pausado = false;
    }

    //quando o botão de pausar simulação for clicado
    public void pausarSimulacao() {
        if (!relogioIniciado) {
            return;
        }

        pausado = true;
    }

    //quando o botão de despausar simulação for clicado
    public void continuarSimulacao() {
        if (!relogioIniciado) {
            return;
        }

        // Descarta todo o tempo real transcorrido durante a pausa.
        ultimoMillisReal = millis();

        pausado = false;
    }

    public void atualizarEntidades(float tempoSimulacao) {
        if (!inicializado) 
        return;

        if (tempoSimulacao >= proximoSpawn) {
            Paciente novoPaciente = new Paciente("P" + contadorPacientes);

            //pra que serve essa condicao? 
            //se for so pra verificar se o gerador e o totem existem, ja tem isso em Grid.pde
            if (grid.getGerador() != null && grid.getTotem() != null) {
                int linhaG = grid.getGerador().getLinha();
                int colunaG = grid.getGerador().getColuna();
                int linhaT = grid.getTotem().getLinha();
                int colunaT = grid.getTotem().getColuna();

                contadorPacientes++;

                novoPaciente.setPosicao(linhaG, colunaG);
                novoPaciente.setDestino(linhaT, colunaT);

                gerenciadorMovimento.registrarPosicaoInicial(novoPaciente, linhaG, colunaG);
                listaPacientes.adicionar(novoPaciente);

                proximoSpawn = tempoSimulacao + geradorTempo.gerarTempoSpawn();
            }
        }
    }

    public void atualizarSimulacao() {
        if (!relogioIniciado || !inicializado) {
            return;
        }

        int agora = millis();

        float delta =
            (agora - ultimoMillisReal) / 1000.0;

        ultimoMillisReal = agora;

        if (pausado) {
            return;
        }

        tempoSimulacao += delta;

        if (tempoSimulacao >= tempoAtualizarSimulacao) {
            atualizarEntidades(tempoSimulacao);

            Paciente[] pacientes = listaPacientes.listaPacientesParaArray();

            gerenciadorMovimento.atualizarMovimentacao(pacientes);

            processarPacientes(pacientes);

            tempoAtualizarSimulacao = tempoSimulacao + tempoEntreAtualizacoes;
        }
    }

    public void processarChegadaTotem(Paciente paciente) {
        if(paciente.getEstado() == EstadoPaciente.INDO_TOTEM && paciente.chegouAoDestino()) {

            int[][] distancias = calcularWavefront(paciente.getLinha(), paciente.getColuna(), grid.getMapaChar());
            Cadeira cadeiras[] = grid.ordenarCadeirasPorDistancia(distancias);
            
            if(cadeiras.length > 0) {
                paciente.setCadeiraAtual(cadeiras[0]);
                paciente.getCadeiraAtual().setEstado(EstadoCadeira.RESERVADA);
                paciente.setDestino(paciente.getCadeiraAtual().getLinha(), paciente.getCadeiraAtual().getColuna());
                paciente.setEstado(EstadoPaciente.INDO_CADEIRA_TRIAGEM);
            }
        }
    }

    public void processarChegadaCadeiraTriagem(Paciente paciente) {
        if(paciente.getEstado() == EstadoPaciente.INDO_CADEIRA_TRIAGEM && paciente.chegouAoDestino()) {
            paciente.getCadeiraAtual().setEstado(EstadoCadeira.OCUPADA);
            paciente.setEstado(EstadoPaciente.AGUARDANDO_TRIAGEM);
            FilasPreferencial.adicionarPaciente(paciente);
        }
    }

    public Coordenada celulaVizinhaAtendimento(int[][] distancias, Coordenada coordenada) {

        int linha = coordenada.getL();
        int coluna = coordenada.getC();
        int altura = grid.getAltura();
        int largura = grid.getLargura();

        int qntCoordenadasLivres = 0;

        //conta as celulas vizinhas livres (que nao sao diagonais) da enfermeira/medico
        for (int i = -1; i <= 1; i++) {
            for(int j = -1; j <= 1; j++) {
                int novaLinha = linha + i;
                int novaColuna = coluna + j;

                if (novaLinha >= 0 && novaLinha < altura && novaColuna >= 0 && novaColuna < largura) {
                    if (!((i + j) % 2 == 0) && distancias[novaLinha][novaColuna] != -1) {
                        qntCoordenadasLivres++;
                    }
                }
            }
        }

        if (qntCoordenadasLivres == 0) {
            return null;
        }
            
        Coordenada[] coordenadasLivre = new Coordenada[qntCoordenadasLivres];

        int contador = 0;

        //cria um objeto Coordenada para cada celula vizinha livre (que nao sao diagonais) da enfermeira/medico
        for (int i = -1; i <= 1; i++) {
            for(int j = -1; j <= 1; j++) {
                int novaLinha = linha + i;
                int novaColuna = coluna + j;

                if (novaLinha >= 0 && novaLinha < altura && novaColuna >= 0 && novaColuna < largura) {
                    if (!((i + j) % 2 == 0) && distancias[novaLinha][novaColuna] != -1) {
                        coordenadasLivre[contador] = new Coordenada(novaLinha, novaColuna);
                        contador++;
                    }
                }
            }
        }

        //ordena as celulas vizinhas livres da enfermeira/medico de acordo com a distancia do paciente 
        for(int i = 0; i < qntCoordenadasLivres; i++) {
            int menor_indice = i;
            int menor_distancia = distancias[coordenadasLivre[i].getL()][coordenadasLivre[i].getC()];

            for(int j = i + 1; j < qntCoordenadasLivres; j++) {
                int distanciaJ = distancias[coordenadasLivre[j].getL()][coordenadasLivre[j].getC()];

                if(distanciaJ < menor_distancia) {
                    menor_indice = j;
                    menor_distancia = distanciaJ;
                }
            }

            Coordenada temporaria = coordenadasLivre[i];
            coordenadasLivre[i] = coordenadasLivre[menor_indice];
            coordenadasLivre[menor_indice] = temporaria;
        }

        return coordenadasLivre[0];
    }

    public void chamarProximoTriagem() {
        
        for(int i = 0; i < enfermeiras.length; i++) {
            if(enfermeiras[i].estado == EstadoProfissional.LIVRE) {
                Paciente paciente = FilasPreferencial.chamarProximo();

                if (paciente != null) {

                    int[][] distancias = calcularWavefront(paciente.getLinha(), paciente.getColuna(), grid.getMapaChar());
                    Coordenada coordenadaEnfermeira = new Coordenada(enfermeiras[i].getLinha(), enfermeiras[i].getColuna());
                    Coordenada coordenadaLivre = celulaVizinhaAtendimento(distancias, coordenadaEnfermeira);

                    if (coordenadaLivre != null) {
                        paciente.setDestino(coordenadaLivre.getL(), coordenadaLivre.getC());
                        paciente.setEstado(EstadoPaciente.INDO_TRIAGEM);
                        enfermeiras[i].setEstado(EstadoProfissional.OCUPADO);
                        paciente.setIndiceEnfermeira(i);
                    }
                }
            }   
        }
    }

    public void processarChegadaTriagem(Paciente paciente) {

        if(paciente.getEstado() == EstadoPaciente.INDO_TRIAGEM && paciente.chegouAoDestino()) {

            paciente.setEstado(EstadoPaciente.EM_TRIAGEM);
            paciente.iniciarTriagem(tempoSimulacao);
        }
    }

    public void processarFimTriagem(Paciente paciente) {

        if(paciente.getEstado() == EstadoPaciente.EM_TRIAGEM && (tempoSimulacao - paciente.getTempoInicioTriagem() >= paciente.getDuracaoTriagem())) {

            Cadeira cadeiraAnterior = paciente.getCadeiraAtual();
            EstadoCadeira estadoAnterior = null;
            if (cadeiraAnterior != null) {
                estadoAnterior = cadeiraAnterior.getEstado();
                cadeiraAnterior.setEstado(EstadoCadeira.LIVRE);
            }

            int[][] distancias = calcularWavefront(paciente.getLinha(), paciente.getColuna(), grid.getMapaChar());
            Cadeira[] cadeiras = grid.ordenarCadeirasPorDistancia(distancias);

            // Aguarda uma cadeira livre e alcancavel antes de encerrar a triagem.
            if (cadeiras.length == 0 || distancias[cadeiras[0].getLinha()][cadeiras[0].getColuna()] == -1) {
                if (cadeiraAnterior != null) {
                    cadeiraAnterior.setEstado(estadoAnterior);
                }
                return;
            }

            paciente.setCorPrioridade(ArvoreDeManchester.decideCorPrioridade(paciente));
            enfermeiras[paciente.getIndiceEnfermeira()].setEstado(EstadoProfissional.LIVRE);
            paciente.setIndiceEnfermeira(-1);

            paciente.setCadeiraAtual(cadeiras[0]);
            paciente.getCadeiraAtual().setEstado(EstadoCadeira.RESERVADA);
            paciente.setDestino(paciente.getCadeiraAtual().getLinha(), paciente.getCadeiraAtual().getColuna());
            paciente.setEstado(EstadoPaciente.INDO_CADEIRA_CONSULTA);
        }
    }

    public void processarChegadaCadeiraConsulta(Paciente paciente) {
        if(paciente.getEstado() == EstadoPaciente.INDO_CADEIRA_CONSULTA && paciente.chegouAoDestino()) {
            paciente.setEstado(EstadoPaciente.AGUARDANDO_CONSULTA);
            FilasPrioridade.adicionarPaciente(paciente);
        }
    }

    public void chamarProximoConsulta() {

        for(int i = 0; i < medicos.length; i++) {
            if(medicos[i].getEstado() == EstadoProfissional.LIVRE) {
                Paciente paciente = FilasPrioridade.chamarProximo();

                if (paciente != null) {

                    int[][] distancias = calcularWavefront(paciente.getLinha(), paciente.getColuna(), grid.getMapaChar());
                    Coordenada coordenadaMedico = new Coordenada(medicos[i].getLinha(), medicos[i].getColuna());
                    Coordenada coordenadaLivre = celulaVizinhaAtendimento(distancias, coordenadaMedico);

                    if (coordenadaLivre != null) {
                        paciente.setDestino(coordenadaLivre.getL(), coordenadaLivre.getC());
                        paciente.setEstado(EstadoPaciente.INDO_CONSULTA);
                        medicos[i].setEstado(EstadoProfissional.OCUPADO);
                    }
                }
                
            }
        }
    }

    public void processarChegadaConsulta(Paciente paciente) {

        if(paciente.getEstado() == EstadoPaciente.INDO_CONSULTA && paciente.chegouAoDestino()) {

            paciente.setEstado(EstadoPaciente.EM_CONSULTA);
            paciente.iniciarConsulta(tempoSimulacao);
        }
    }

    private void processarPacientes(Paciente[] pacientes) {
        for (int i = 0; i < pacientes.length; i++) {
            Paciente paciente = pacientes[i];

            processarChegadaTotem(paciente);
            processarChegadaCadeiraTriagem(paciente);
            processarChegadaTriagem(paciente);
            processarFimTriagem(paciente);
            processarChegadaCadeiraConsulta(paciente);
            processarChegadaConsulta(paciente);

            if (grid.getRemovedor() != null) {
                Coordenada coordenadaRemovedor =
                    new Coordenada(grid.getRemovedor().getLinha(), grid.getRemovedor().getColuna());

                paciente.atualizar(tempoSimulacao, coordenadaRemovedor, listaPacientes);
            }
        }

        chamarProximoTriagem();
        chamarProximoConsulta();
    }

    //quando a simulacao for resetada
    public void resetarRelogio() {
        tempoSimulacao = 0;
        tempoAtualizarSimulacao = 0;
        proximoSpawn = 0;

        ultimoMillisReal = millis();

        relogioIniciado = false;
        pausado = true;
    }

    public boolean estaPausado() {
        return pausado;
    }

    public boolean estaIniciada() {
        return relogioIniciado;
    }

    public float getTempoSimulacao() {
        return tempoSimulacao;
    }
}