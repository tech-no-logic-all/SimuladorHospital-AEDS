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

    float tempoAtual = millis() / 1000.0;

    simulador.iniciarGrid();
    simulador.atualizarEntidades(tempoAtual);
}