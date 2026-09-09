public class GerenciadorMovimento{
    private char[][] mapaBase;
    private Paciente[][] ocupacao; //mapinha que mostra onde ta cada paciente

    private int numLinhas;
    private int numColunas;

    public GerenciadorMovimento(char[][] mapaBase){
        this.mapaBase = mapaBase;
        this.numLinhas = mapaBase.length;
        this.numColunas = mapaBase[0].length;

        this.ocupacao = new Paciente[numLinhas][numColunas];
    }

    public void registrarPosicaoInicial(Paciente p, int linha, int coluna){
        if (!estaLivre(linha, coluna)) {
            throw new IllegalStateException("Celula de entrada ocupada.");
        }
        p.setPosicao(linha, coluna);
        ocupacao[linha][coluna] = p;
    }

    public boolean estaLivre(int linha, int coluna) {
        return ocupacao[linha][coluna] == null;
    }

    public void removerPaciente(Paciente p) {
        if (ocupacao[p.getLinha()][p.getColuna()] == p) {
            ocupacao[p.getLinha()][p.getColuna()] = null;
        }
    }

    public Coordenada calcularIntencao(Paciente p){
        if(p.chegouAoDestino()){
            return null;
        }
        char[][] mapaMovimentacao = copiarMapaComCadeirasOcupadas(p);
        int[][] distancias = calcularWavefront(p.getDestinoLinha(), p.getDestinoColuna(), mapaMovimentacao); //salva na matriz a onda pra saber as distancias
        Coordenada[] candidatos = vizinhosOrdenadosPorDistancia(p.getLinha(), p.getColuna(), distancias); //ordena as casas vizinhas pra saber a mais proxima do destino
        int distanciaAtual = distancias[p.getLinha()][p.getColuna()];
        if(candidatos.length == 0){
            return null; //nao tem pra onde ir
        }
        for(int i=0; i<candidatos.length; i++){ //serve pra conferir se a casa mais top ja esta ocupada
            int distanciaCandidato = distancias[candidatos[i].getL()][candidatos[i].getC()];
            if(distanciaCandidato < distanciaAtual && ocupacao[candidatos[i].getL()][candidatos[i].getC()] == null){
                return candidatos[i]; //se nao tiver retorna ela
            }
        }
        return null; //se sair do for e nao tiver nenhuma livre ele fica parado (null)
    }

    private char[][] copiarMapaComCadeirasOcupadas(Paciente pacienteEmMovimento) {
        char[][] copia = new char[numLinhas][numColunas];

        for (int linha = 0; linha < numLinhas; linha++) {
            for (int coluna = 0; coluna < numColunas; coluna++) {
                copia[linha][coluna] = mapaBase[linha][coluna];

                if (mapaBase[linha][coluna] == 'A'
                    && ocupacao[linha][coluna] != null
                    && ocupacao[linha][coluna] != pacienteEmMovimento) {
                    copia[linha][coluna] = '#';
                }
            }
        }

        return copia;
    }

    void atualizarMovimentacao(Paciente[] pacientesAtivos) {
        Coordenada[] intencoes = new Coordenada[pacientesAtivos.length];

        for(int i=0; i<intencoes.length; i++){
            intencoes[i] = calcularIntencao(pacientesAtivos[i]);
        }

        boolean[] podeMover = resolverConflitos(pacientesAtivos, intencoes);
        aplicarMovimentos(pacientesAtivos, intencoes, podeMover);

    }

    boolean[] resolverConflitos(Paciente[] pacientesAtivos, Coordenada[] intencoes) {
        boolean[] podeMover = new boolean[pacientesAtivos.length];
        for(int i=0; i<pacientesAtivos.length; i++){ 
            if(intencoes[i] != null){
                podeMover[i] = true; //colocando todos que tem inteçao de mover pra poder mover
            }
        }

        for(int i=0; i<pacientesAtivos.length; i++){ //dois querem ir pro mesmo lugar
            for(int j=0; j<pacientesAtivos.length; j++){
                if(i<j){ //pra naao comparar duas vezes 
                    if(intencoes[i] != null && intencoes[j] != null){  
                        if(intencoes[i].equals(intencoes[j])){
                            podeMover[j] = false; //o primeiro do array move
                        }
                    }
                }
            }
        }

        boolean mudou = true; //isso resolve o seguinte problema:
        //A quer ir pra célula de B, B quer ir pra célula de C, e C não vai se mover
        while(mudou){
            mudou = false;
            for(int i=0; i<pacientesAtivos.length; i++){ //um quer ir pra onde ja tem outro
                if(podeMover[i]){
                    Coordenada alvo = intencoes[i]; //guarda as coordenadas da casa que queremos ir
                    Paciente ocupante = ocupacao[alvo.getL()][alvo.getC()]; //pega quem ta no lugar que queremos ir

                    if(ocupante != null){  //se tem alguem la
                        if(ocupante != pacientesAtivos[i]){ //se nao é voce mesmo
                            int indiceOcup = -1; 
                            for(int k=0; k<pacientesAtivos.length; k++){ 
                                if(pacientesAtivos[k] == ocupante){ //acha quem é o paciente que ta la
                                    indiceOcup = k;
                                }
                            }
                            if(indiceOcup == -1 || !podeMover[indiceOcup]){ //olha se ele vai sair de la
                                podeMover[i] = false; //se ele nao vai, voce nao move
                                mudou = true;
                            }
                        }
                    }
                }
            }
        }
        

        for(int i=0; i<pacientesAtivos.length; i++){ //se um quer ir pro lugar do outro
            for(int j=0; j<pacientesAtivos.length; j++){
                if(i < j){
                    if(podeMover[i] && podeMover[j]){
                        if(intencoes[i].equals(new Coordenada(pacientesAtivos[j].getLinha(), pacientesAtivos[j].getColuna()))){
                            if(intencoes[j].equals(new Coordenada(pacientesAtivos[i].getLinha(), pacientesAtivos[i].getColuna()))){
                                podeMover[i] = false;
                                podeMover[j] = false; //ninguem move
                            }
                        }
                    }
                }
            }
        }
        return podeMover;
    }

    void aplicarMovimentos(Paciente[] pacientesAtivos, Coordenada[] intencoes, boolean[] podeMover){
        for(int i=0; i<pacientesAtivos.length; i++){
            if(podeMover[i]){
                ocupacao[pacientesAtivos[i].getLinha()][pacientesAtivos[i].getColuna()] = null; //desocupa a celula
                Coordenada alvo = intencoes[i]; //pega as coordenadas de pra onde quer ir
                pacientesAtivos[i].setPosicao(alvo.getL(), alvo.getC()); //coloca o posicao no paciente
                ocupacao[alvo.getL()][alvo.getC()] = pacientesAtivos[i]; //coloca o paciente na matriz ocupacao
            }
        }
    }
}