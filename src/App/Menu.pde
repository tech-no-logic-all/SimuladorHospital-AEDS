EstadoJogo estadoAtual = EstadoJogo.MENU_PRINCIPAL;
String[] mapasDisponiveis;
int mapaSelecionado = -1;

void carregarListaDeMapas() {
    File pastaData = new File(dataPath(""));
    String[] arquivos = pastaData.list();
    if (arquivos == null) arquivos = new String[0];
    java.util.Arrays.sort(arquivos);

    int total = 0;
    for (int i = 0; i < arquivos.length; i++) {
        if (arquivos[i].endsWith(".txt")) { //filtra pra n pegar imagens 
            total++; //conta qtd de arquivos
        }
    }

    mapasDisponiveis = new String[total];
    int indice = 0;
    for (int i = 0; i < arquivos.length; i++) {
        if (arquivos[i].endsWith(".txt")) { //tira o .txt dos nomes
            mapasDisponiveis[indice] = arquivos[i].substring(0, arquivos[i].length() - 4);
            indice++;
        }
    }
}

void desenharMenuInicial() {
    background(245);

    fill(30);
    textAlign(CENTER, CENTER);
    textSize(26);
    text("Simulador Hospitalar - Escolha um mapa", width / 2, 50);

    textSize(16);
    for (int i = 0; i < mapasDisponiveis.length; i++) { //desenha os botoes retangulares
        float bx = width / 2 - 150;
        float by = 100 + i * 60;
        float bw = 300;
        float bh = 45;

        if (i == mapaSelecionado) {
            fill(150, 200, 255);
        } else {
            fill(225);
        }
        rect(bx, by, bw, bh, 8);

        fill(20);
        text(mapasDisponiveis[i], bx + bw / 2, by + bh / 2);
    }

    float ibx = width / 2 - 110;
    float iby = height - 90;
    float ibw = 220;
    float ibh = 50;

    if (mapaSelecionado == -1) {
        fill(210);
    } else {
        fill(120, 200, 140);
    }
    rect(ibx, iby, ibw, ibh, 8); 

    fill(20);
    text("Iniciar Simulação", ibx + ibw / 2, iby + ibh / 2);
}

void tratarCliqueMenuInicial(int mx, int my) { //mx e my mouse x e y
    for (int i = 0; i < mapasDisponiveis.length; i++) {
        float bx = width / 2 - 150;
        float by = 100 + i * 60;
        float bw = 300;
        float bh = 45;

        if (mx >= bx && mx <= bx + bw && my >= by && my <= by + bh) {
            mapaSelecionado = i; //se tiver clique em algum botao mapa selecionado
            return;
        }
    }

    float ibx = width / 2 - 110;
    float iby = height - 90;
    float ibw = 220;
    float ibh = 50;

    boolean clicouIniciar = mx >= ibx && mx <= ibx + ibw && my >= iby && my <= iby + ibh;

    if (mapaSelecionado != -1 && clicouIniciar) {
        String caminho = "data/" + mapasDisponiveis[mapaSelecionado] + ".txt";
        simulador.iniciarGrid(caminho); //manda o caminho do mapa montado em cima

        if (simulador.estaInicializado()) {
            simulador.iniciarSimulacao();
            estadoAtual = EstadoJogo.SIMULACAO_MAPA;
        }
    }
}

void desenharBotaoPausarSimulacao() {
    fill(230);
    rect(width - 120, 10, 110, 36, 8);

    fill(20);
    textAlign(CENTER, CENTER);
    textSize(13);
    text("Pausar (ESC)", width - 65, 28);
}

boolean cliqueNoBotaoPausar(int mx, int my) {
    return dentroBotao(mx, my, width - 65, 28, 110, 36);
}

void desenharMenuPausa() {
    simulador.desenharGrid(); // grid "congelado" por baixo

    noStroke();
    fill(0, 150);
    rect(0, 0, width, height);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(28);
    text("Pausado", width / 2, height / 2 - 130);

    desenharBotaoPausa("Continuar", width / 2, height / 2 - 40);
    desenharBotaoPausa("Resetar", width / 2, height / 2 + 20);
    desenharBotaoPausa("Voltar ao Menu Inicial", width / 2, height / 2 + 80);
}

void desenharBotaoPausa(String texto, float cx, float cy) {
    float bw = 260;
    float bh = 45;

    fill(230);
    rect(cx - bw / 2, cy - bh / 2, bw, bh, 8);

    fill(20);
    textSize(16);
    text(texto, cx, cy);
}

boolean dentroBotao(float mx, float my, float cx, float cy, float bw, float bh) { //funçao auxiliar pra ver se a pessoa colocou o mouse dentro dos limites do botao
    return mx >= cx - bw / 2 && mx <= cx + bw / 2 &&
           my >= cy - bh / 2 && my <= cy + bh / 2;
}

void tratarCliqueMenuPausa(int mx, int my) {
    float cx = width / 2;
    float bw = 260;
    float bh = 45;

    if (dentroBotao(mx, my, cx, height / 2 - 40, bw, bh)) {
        // Continuar
        simulador.continuarSimulacao();
        estadoAtual = EstadoJogo.SIMULACAO_MAPA;

    } else if (dentroBotao(mx, my, cx, height / 2 + 20, bw, bh)) {
        // Resetar
        String caminho = "data/" + mapasDisponiveis[mapaSelecionado] + ".txt";
        simulador.reiniciarSimulacao(caminho);
        if (simulador.estaInicializado()) {
            simulador.iniciarSimulacao();
            estadoAtual = EstadoJogo.SIMULACAO_MAPA;
        } else {
            estadoAtual = EstadoJogo.MENU_PRINCIPAL;
        }

    } else if (dentroBotao(mx, my, cx, height / 2 + 80, bw, bh)) {
        // Voltar ao Menu Inicial
        estadoAtual = EstadoJogo.MENU_PRINCIPAL;
        mapaSelecionado = -1;
    }
}