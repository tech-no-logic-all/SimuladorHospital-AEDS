public class Grid {
    private int largura, altura;
    private int largura_celula;
    private int altura_celula;

    private Gerador gerador;
    private Totem totem; //decidi colocar apenas um totem no mapa, apesar de nao ser explicito nas instrucoes
    private Removedor removedor;
    private Medico[] medico;
    private Enfermeira[] enfermeira;
    
    private CelulasGrid[][] grid;
    private Cadeira[] cadeiras;
    private char[][] mapaChar;

    private boolean tem_gerador;
    private boolean tem_removedor;
    private boolean tem_medico;
    private boolean tem_enfermeira;
    private boolean tem_totem;

    private PImage chao_img = new PImage();
    private PImage parede_img = new PImage();
    private PImage cadeira_img = new PImage();
    private PImage gerador_img = new PImage();
    private PImage removedor_img = new PImage();
    private PImage enfermeira_img = new PImage();
    private PImage medico_img = new PImage();
    private PImage totem_img = new PImage();

    void inicializarImagens() {
        chao_img = loadImage("tilefloor.png");
        parede_img = loadImage("tilewall.png");
        cadeira_img = loadImage("chair.png");
        gerador_img = loadImage("gerador.png");
        removedor_img = loadImage("removedor.png");
        medico_img = loadImage("doctor.png");
        enfermeira_img = loadImage("nurse.png");
        totem_img = loadImage("totem.png");
    }

    void inicializarGrid(String caminhoMapa) throws MapaNaoFormatadoException {
        int i, j;
        int contadorMedicos = 0, contadorEnfermeiras = 0, contadorCadeiras = 0;
        int qnt_medicos = 0, qnt_enfermeiras = 0, qnt_cadeiras = 0;
        
        String[] linhasMapa = loadStrings(caminhoMapa);

        try {
            String[] dimensoes = split(linhasMapa[0], ' ');
            altura = int(dimensoes[0]);
            largura = int(dimensoes[1]);
        } catch (ArrayIndexOutOfBoundsException e) {
            //preferi tratar assim porque, nesse caso, o mapa tambem nao esta formatado como deveria
            throw new MapaNaoFormatadoException();
        }

        //se a qnt de linhas nao bater com o que foi declarado na primeira linha,
        //lanca a excecao
        if(altura != linhasMapa.length - 1) {
            throw new MapaNaoFormatadoException();
        }

        grid = new CelulasGrid[altura][largura];
        largura_celula = width / largura;
        altura_celula = height / altura;

        for(i = 0; i < altura; i++) {
            for(j = 0; j < largura; j++) {
                grid[i][j] = new CelulasGrid();
            }
        }

        mapaChar = new char[altura][largura];

        for(i = 0; i < altura; i++) {

            //1a linha eh o tamanho do mapa
            String linha = linhasMapa[i + 1];

            //se a qnt de colunas nao bater com o que foi declarado na primeira linha,
            //lanca a excecao
            if (linha.length() != largura) {
                throw new MapaNaoFormatadoException();
            }

            for(j = 0; j < largura; j++) {
        
                char c = linha.charAt(j);
                mapaChar[i][j] = c;
                
                switch (c) {
                    case '#':
                        grid[i][j].setTipoCelula(Celulas.p);
                        break;

                    case '.':
                        grid[i][j].setTipoCelula(Celulas.c);
                        break;

                    case 'A':
                        grid[i][j].setTipoCelula(Celulas.a);
                        qnt_cadeiras++;
                        break;

                    case 'M':
                        grid[i][j].setTipoCelula(Celulas.m);
                        qnt_medicos++;
                        break;

                    case 'E':
                        grid[i][j].setTipoCelula(Celulas.e);
                        qnt_enfermeiras++;
                        break;

                    case 'T':
                        grid[i][j].setTipoCelula(Celulas.t);
                        break;

                    case 'G':
                        grid[i][j].setTipoCelula(Celulas.g);
                        break;

                    case 'R':
                        grid[i][j].setTipoCelula(Celulas.r);
                        break;

                    default:
                        throw new MapaNaoFormatadoException();
                }
            }
        }

        medico = new Medico[qnt_medicos];
        enfermeira = new Enfermeira[qnt_enfermeiras];
        cadeiras = new Cadeira[qnt_cadeiras];

        for(i = 0; i < altura; i++) {
            for(j = 0; j < largura; j++) {

                switch (grid[i][j].getTipoCelula()) {
                    case p:
                        grid[i][j].setFundo(parede_img);
                        grid[i][j].setAcessorio(null);
                        break;

                    case c:
                        grid[i][j].setFundo(chao_img);
                        grid[i][j].setAcessorio(null);
                        break;

                    case a:
                        grid[i][j].setFundo(chao_img);
                        grid[i][j].setAcessorio(cadeira_img);

                        cadeiras[contadorCadeiras] = new Cadeira(i, j);
                        contadorCadeiras++;
                        break;

                    case m:
                        grid[i][j].setFundo(chao_img);
                        grid[i][j].setAcessorio(medico_img);

                        medico[contadorMedicos] = new Medico(i, j);
                        tem_medico = true;
                        contadorMedicos++;
                        break;

                    case e:
                        grid[i][j].setFundo(chao_img);
                        grid[i][j].setAcessorio(enfermeira_img);

                        enfermeira[contadorEnfermeiras] = new Enfermeira(i, j);
                        tem_enfermeira = true;
                        contadorEnfermeiras++;
                        break;

                    case t:
                        grid[i][j].setFundo(chao_img);
                        grid[i][j].setAcessorio(totem_img);
                        
                        if(tem_totem) {
                            throw new MapaNaoFormatadoException();
                        } else {
                            tem_totem = true;
                        }

                        totem = new Totem(i, j);

                        break;

                    case g:
                        grid[i][j].setFundo(chao_img);
                        grid[i][j].setAcessorio(gerador_img);

                        if(tem_gerador) {
                            throw new MapaNaoFormatadoException();
                        } else {
                            tem_gerador = true;
                        }
                        gerador = new Gerador(i, j);
                        break;

                    case r:
                        grid[i][j].setFundo(chao_img);
                        grid[i][j].setAcessorio(removedor_img);
                        
                        if(tem_removedor) {
                            throw new MapaNaoFormatadoException();
                        } else {
                            tem_removedor = true;
                        }
                        removedor = new Removedor(i, j);
                        break;
                }
            }
        }

        if(!tem_gerador || !tem_removedor || !tem_medico || !tem_enfermeira || !tem_totem) {
            throw new MapaNaoFormatadoException();
        }

        if (!validarCaminhosTransitaveis()) {  
            throw new MapaNaoFormatadoException();
        }
    }

    int qnt_livrescadeiras = 0;

    void desenharGrid() {
        int i, j;

        for(i = 0; i < altura; i++) {
            for(j = 0; j < largura; j++) {

                switch(grid[i][j].getTipoCelula()) {

                    case p:
                        image(grid[i][j].getFundo(), 
                            j * largura_celula, 
                            i * altura_celula, 
                            largura_celula, altura_celula);
                        break;

                    case c:
                        image(grid[i][j].getFundo(), 
                            j * largura_celula, 
                            i * altura_celula, 
                            largura_celula, altura_celula);
                        break;

                    case a:
                        image(grid[i][j].getFundo(), 
                            j * largura_celula, 
                            i * altura_celula, 
                            largura_celula, altura_celula);
                        image(grid[i][j].getAcessorio(), 
                            j * largura_celula, 
                            i * altura_celula, 
                            largura_celula, altura_celula);
                        break;

                    case m:
                        image(grid[i][j].getFundo(), 
                            j * largura_celula, 
                            i * altura_celula, 
                            largura_celula, altura_celula);
                        image(grid[i][j].getAcessorio(), 
                            j * largura_celula, 
                            i * altura_celula, 
                            largura_celula, altura_celula);
                        break;

                    case e:
                        image(grid[i][j].getFundo(), 
                            j * largura_celula, 
                            i * altura_celula, 
                            largura_celula, altura_celula);
                        image(grid[i][j].getAcessorio(), 
                            j * largura_celula, 
                            i * altura_celula, 
                            largura_celula, altura_celula);
                        break;

                    case t:
                        image(grid[i][j].getFundo(), 
                            j * largura_celula, 
                            i * altura_celula, 
                            largura_celula, altura_celula);
                        image(grid[i][j].getAcessorio(), 
                            j * largura_celula, 
                            i * altura_celula, 
                            largura_celula, altura_celula);
                        break;

                    case g:
                        image(grid[i][j].getFundo(), 
                            j * largura_celula, 
                            i * altura_celula, 
                            largura_celula, altura_celula);
                        image(grid[i][j].getAcessorio(), 
                            j * largura_celula, 
                            i * altura_celula, 
                            largura_celula, altura_celula);
                        break;

                    case r:
                        image(grid[i][j].getFundo(), 
                            j * largura_celula, 
                            i * altura_celula, 
                            largura_celula, altura_celula);
                        image(grid[i][j].getAcessorio(), 
                            j * largura_celula, 
                            i * altura_celula, 
                            largura_celula, altura_celula);
                        break;
                }
            }
        }
    }

    private boolean validarCaminhosTransitaveis() {
        int[][] distancias = calcularWavefront(gerador.getLinha(), gerador.getColuna(), mapaChar);

        // totem e removedor sao celulas transitaveis
        if (distancias[totem.getLinha()][totem.getColuna()] == -1 || distancias[removedor.getLinha()][removedor.getColuna()] == -1) {
            return false;
        }

        // assentos: mesma logica, sao transitaveis
        for (int i = 0; i < cadeiras.length; i++) {
            if (distancias[cadeiras[i].getLinha()][cadeiras[i].getColuna()] == -1) {
                return false;
            }
        }

        // medicos e enfermeiras: o wavefront trata como parede (paciente nao pisa neles),
        // entao valida se pelo menos um vizinho de chao foi alcancado
        for (int i = 0; i < medico.length; i++) {
            if (!temVizinhoAlcancavel(medico[i].getLinha(), medico[i].getColuna(), distancias)) {
                return false;
            }
        }
        for (int i = 0; i < enfermeira.length; i++) {
            if (!temVizinhoAlcancavel(enfermeira[i].getLinha(), enfermeira[i].getColuna(), distancias)) {
                return false;
            }
        }

        return true;
    }

    private boolean temVizinhoAlcancavel(int linha, int coluna, int[][] distancias) {

        for (int i = -1; i <= 1; i++) {
            for(int j = -1; j <= 1; j++) {
                int novaLinha = linha + i;
                int novaColuna = coluna + j;

                if (novaLinha >= 0 && novaLinha < altura && novaColuna >= 0 && novaColuna < largura) {
                    if (!((i + j) % 2 == 0) && distancias[novaLinha][novaColuna] != -1) {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    public Cadeira[] ordenarCadeirasPorDistancia(int[][] distancias) {
        //pega so as cadeiras livres pra ordenar
        Cadeira[] cadeirasLivres = filtrarCadeirasLivres();
        int n = cadeirasLivres.length;

        //ordenando com insertion sort
        for(int i = 0; i < n; i++) {
            int menor_indice = i;
            int menor_distancia = distanciaReal(cadeirasLivres[i], distancias);

            for(int j = i + 1; j < n; j++) {
                int distanciaJ = distanciaReal(cadeirasLivres[j], distancias);

                if(distanciaJ < menor_distancia) {
                    menor_indice = j;
                    menor_distancia = distanciaJ;
                }
            }

            Cadeira temporaria = cadeirasLivres[i];
            cadeirasLivres[i] = cadeirasLivres[menor_indice];
            cadeirasLivres[menor_indice] = temporaria;
        }

        return cadeirasLivres;
    }

    //verifica se nao eh impossivel chegar
    //util para a ordenacao pois, se for impossivel chegar, coloca com o maior numero inteiro possivel
    public int distanciaReal(Cadeira cadeira, int[][] distancias) {
        int distancia_real = distancias[cadeira.getLinha()][cadeira.getColuna()];

        if(distancia_real == -1) {
            distancia_real = Integer.MAX_VALUE;
        }

        return distancia_real;
    }

    //retorna um array com as cadeiras livres
    public Cadeira[] filtrarCadeirasLivres() {
        int qnt_livres = 0;
        int contador = 0;

        for (int i = 0; i < cadeiras.length; i++) {
            if (cadeiras[i].getEstado() == EstadoCadeira.LIVRE) {
                qnt_livres++;
            }
        }

        Cadeira[] cadeirasLivres = new Cadeira[qnt_livres];

        for (int i = 0; i < cadeiras.length; i++) {
            if (cadeiras[i].getEstado() == EstadoCadeira.LIVRE) {
                cadeirasLivres[contador] = cadeiras[i];
                contador++;
            }
        }
        return cadeirasLivres;
    }

    //chamar quando um novo mapa for escolhido
    public void resetarGrid() {
        grid = null;
        cadeiras = null;
        largura = 0;
        altura = 0;
        largura_celula = 0;
        altura_celula = 0;
        tem_gerador = false;
        tem_removedor = false;
        tem_medico = false;
        tem_enfermeira = false;
        tem_totem = false;
    }

    public char[][] getMapaChar() {
    return mapaChar;
    }

    public Gerador getGerador() {
    return gerador;
    }

    public Totem getTotem() {
    return totem;
    }

    public Removedor getRemovedor() {
    return removedor;
    }
}