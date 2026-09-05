public class SimuladorHospital {

    private Grid grid;
    private GeradorTempo geradorTempo;
    private ListaPacientes listaPacientes;
    private GerenciadorMovimento gerenciadorMovimento;

    private boolean inicializado = false;
    private int contadorPacientes = 0;
    private float proximoSpawn = 0;

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
        proximoSpawn = geradorTempo.gerarTempoSpawn();
    }

    public void iniciarGrid (Grid grid) {

        if (!inicializado) {

            try {
                //vai ser chamado sempre que um mapa diferente for escolhido, para resetar o grid e desenhar o novo mapa
                grid.inicializarGrid("data/mapa1.txt");
                gerenciadorMovimento = new GerenciadorMovimento(grid.getMapaChar());
                inicializado = true;

            } catch (MapaNaoFormatadoException e) {
                println(e.getMessage());
                return;
            }   
        }
        grid.desenharGrid();
    }

    public void atualizarEntidades(float tempoAtual) {
        if (!inicializado) 
        return;

        if (tempoAtual >= proximoSpawn) {
            contadorPacientes++;
            Paciente novoPaciente = new Paciente("P" + contadorPacientes);

            if (grid.getGerador() != null && grid.getTotem() != null) {
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