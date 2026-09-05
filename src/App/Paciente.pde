import java.util.Random;

public class Paciente {
    
    public static final int SATURACAO = 0;
    public static final int TEMPERATURA = 1;
    public static final int NIVEL_DOR = 2;
    public static final int CONSCIENCIA = 3;

    private String id;
    private double[] caracteristicas;
    private boolean preferencial;
    private CoresPrioridades corPrioridade;

    private final Random rand = new Random();

    private int linha;
    private int coluna;
    private int destinoLinha;
    private int destinoColuna;

    private EstadoPaciente estado;
    private float tempoInicioAtendimento;
    private float duracaoAtendimento;



    public Paciente(String id) {
        this.id = id;
        this.estado = EstadoPaciente.INDO_TOTEM;
        this.caracteristicas = gerarCaracteristicasAleatorias();

        if(rand.nextDouble() < 0.25) {
            preferencial = true;
        } else {
            preferencial = false;
        }
    }

    
    private double[] gerarCaracteristicasAleatorias() {
        
        double[] c = new double[4];

        // geração das caracteriticas aleatorias
        c[SATURACAO]   = 70 + rand.nextDouble() * (100 - 70); // 70 + um número de ponto flutuante aleatório entre 0 e 1 * a diferença do intervalo 
        c[TEMPERATURA] = 34 + rand.nextDouble() * (42 - 34); // mesma logica
        c[NIVEL_DOR]   = rand.nextInt(11); // número aleatório entre 0 e 10
        c[CONSCIENCIA] = rand.nextInt(2); // mesma logica

        return c;
    }

    public double getCaracteristica(int indice) {
        return caracteristicas[indice];
    }
    
    public boolean getPreferencial() {
        return preferencial;
    }

    public CoresPrioridades getCorPrioridade() {
        return corPrioridade;
    }

    public void setCorPrioridade(CoresPrioridades cor) {
        this.corPrioridade = cor;
    }


    public String getId(){
        return id;
    }

    public void setId(String id){
        this.id = id;
    }



    public int getLinha(){
        return linha;
    }

    public int getColuna(){
        return coluna;
    }

    public void setPosicao(int l, int c){
        this.linha = l;
        this.coluna = c;
    }

    public void setDestino(int l, int c){
        this.destinoLinha = l;
        this.destinoColuna = c;
    }

    public int getDestinoLinha(){
        return destinoLinha;
    }

    public int getDestinoColuna(){
        return destinoColuna;
    }

    public boolean chegouAoDestino(){
        if(this.linha == this.destinoLinha && this.coluna == this.destinoColuna){
            return true;
        }
        return false;
    }

    public EstadoPaciente getEstado() {
        return estado;
    }

    public void setEstado(EstadoPaciente estado) {
        this.estado = estado;
    }

    public void iniciarConsulta(float tempoAtual) {
        this.tempoInicioAtendimento = tempoAtual;
        GeradorTempo gerador = new GeradorTempo();
        this.duracaoAtendimento = gerador.gerarTempoConsulta();
    }

    public void atualizar(float tempoAtual, Coordenada coordRemovedor, ListaPacientes listaPacientes) {
        if (this.estado == EstadoPaciente.EM_CONSULTA) {
            if (tempoAtual - this.tempoInicioAtendimento >= this.duracaoAtendimento) {
                this.estado = EstadoPaciente.INDO_SAIDA;
                setDestino(coordRemovedor.linha, coordRemovedor.coluna);
            }
        }

        if (this.estado == EstadoPaciente.INDO_SAIDA) {
            if (chegouAoDestino()) {

                this.estado = EstadoPaciente.INDO_SAIDA;;
                listaPacientes.removerPorId(this.id);
            }
        }
    }
}