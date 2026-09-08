public class Enfermeira {
    private int linha, coluna;
    EstadoEnfermeira estado;

    public Enfermeira(int linha, int coluna) {
        this.linha = linha;
        this.coluna = coluna;
        this.estado = EstadoEnfermeira.LIVRE;
    }

    public int getColuna() {
        return coluna;
    }

    public int getLinha() {
        return linha;
    }

    public void setEstado(EstadoEnfermeira estado) {
        this.estado = estado;
    }

    public EstadoEnfermeira getEstado() {
        return estado;
    }
}