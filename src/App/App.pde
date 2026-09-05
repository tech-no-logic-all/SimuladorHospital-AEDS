NoManchester[] ArvoreManchester;

Grid grid;

//apenas teste, talvez a logica deva ser alterada
boolean inicializado = false;

GeradorTempo geradorTempo;
ListaPacientes listaPacientes;
GerenciadorMovimento gerenciadorMovimento;

float proximoSpawn = 0;
int contadorPacientes = 0;

void setup() {
    size(800, 800);
    inicializado = false;

    grid = new Grid();

    grid.inicializarImagens();

    geradorTempo = new GeradorTempo();
    listaPacientes = new ListaPacientes();

    proximoSpawn = geradorTempo.gerarTempoSpawn();


    /* 
    
    logica de manchester:
        -> se existe um paciente no totem de atendimento  
        -> chama metodo que passa pela arvore e retorna uma cor  
        -> cor vira atributo de paciente
        -> paciente vai pra fila de espera da consulta
        
    */
}

void draw() {
    background(255);

    if (!inicializado) {
        try {
            //vai ser chamado sempre que um mapa diferente for escolhido, para resetar o grid e desenhar o novo mapa
            grid.inicializarGrid("data/mapa1.txt");
            inicializado = true;
            gerenciadorMovimento = new GerenciadorMovimento(grid.getMapaChar());

        } catch (MapaNaoFormatadoException e) {
            println(e.getMessage());
        }
    }

    if(inicializado) {
        grid.desenharGrid();

        float tempoAtual = millis() / 1000.0;

        if (tempoAtual >= proximoSpawn) {
            contadorPacientes++;
            Paciente novoPaciente = new Paciente("P" + contadorPacientes);
            
            int linhaG = grid.getGerador().getLinha();
            int colunaG = grid.getGerador().getColuna();
            int linhaT = grid.getTotem().getLinha();
            int colunaT = grid.getTotem().getColuna();

            novoPaciente.setPosicao(linhaG, colunaG);
            novoPaciente.setDestino(linhaT, colunaT);

            gerenciadorMovimento.registrarPosicaoInicial(novoPaciente, linhaG, colunaG);
            listaPacientes.adicionar(novoPaciente);

            proximoSpawn = tempoAtual + geradorTempo.gerarTempoSpawn();
        }
    }
}