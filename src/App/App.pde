NoManchester[] ArvoreManchester;

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

    simulador = new SimuladorHospital();
    simulador.setup();

    carregarListaDeMapas();
}

void draw() {
    switch (estadoAtual) {
        case MENU_PRINCIPAL:
            desenharMenuInicial();
            break;

        case SIMULACAO_MAPA:
            background(255);
            simulador.atualizarSimulacao();
            simulador.desenharGrid();
            desenharBotaoPausarSimulacao();
            break;

        case PAUSA:
            desenharMenuPausa();
            break;
    }
}

void mousePressed() {
    switch (estadoAtual) {
        case MENU_PRINCIPAL:
            tratarCliqueMenuInicial(mouseX, mouseY);
            break;

        case SIMULACAO_MAPA:
            if (cliqueNoBotaoPausar(mouseX, mouseY)) {
                simulador.pausarSimulacao();
                estadoAtual = EstadoJogo.PAUSA;
            }
            break;

        case PAUSA:
            tratarCliqueMenuPausa(mouseX, mouseY);
            break;
    }
}

void keyPressed() {
    if (key == ESC) {
        key = 0; // impede o Processing de fechar o sketch com ESC

        if (estadoAtual == EstadoJogo.SIMULACAO_MAPA) {
            simulador.pausarSimulacao();
            estadoAtual = EstadoJogo.PAUSA;

        } else if (estadoAtual == EstadoJogo.PAUSA) {
            simulador.continuarSimulacao();
            estadoAtual = EstadoJogo.SIMULACAO_MAPA;
        }
    }
}