public class Medico {
    private int linha, coluna;
    EstadoProfissional estado;

    public Medico(int linha, int coluna) {
        this.linha = linha;
        this.coluna = coluna;
        this.estado = EstadoProfissional.LIVRE;
    }

    public int getColuna() {
        return coluna;
    }

    public int getLinha() {
        return linha;
    }

    public void setEstado(EstadoProfissional estado) {
        this.estado = estado;
    }
    
    public EstadoProfissional getEstado() {
        return estado;
    }
}