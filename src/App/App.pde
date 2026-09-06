NoManchester[] ArvoreManchester;

Grid grid;

//apenas teste, talvez a logica deva ser alterada
boolean inicializado = false;

GeradorTempo geradorTempo;
ListaPacientes listaPacientes;
GerenciadorMovimento gerenciadorMovimento;

float proximoSpawn = 0;
int contadorPacientes = 0;

SimuladorHospital simulador;

void setup() {
    
    size(800, 800);
    inicializado = false;

    grid = new Grid();

    grid.inicializarImagens();

    geradorTempo = new GeradorTempo();
    listaPacientes = new ListaPacientes();

    proximoSpawn = geradorTempo.gerarTempoSpawn();

    simulador = new SimuladorHospital();


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

    float tempoAtual = millis() / 1000.0;

    //esse iniciarGrid acho q tem que mandar uma string pro caminho do arquivo do mapa .txt
    //simulador.iniciarGrid();
    
    /*mudei esse metodo pra ser chamado dentro da própria classe SimuladorHospital
    basicamente, aq agora vai ser chamado o metodo de atualizarSimulacao, pq ai ele cuida de todo o resto:
    * atualiza entidades
    * atualiza movimentacao
    tudo com a verificacao de tempo */
    //simulador.atualizarEntidades(tempoAtual);
    simulador.atualizarSimulacao(tempoAtual);
}