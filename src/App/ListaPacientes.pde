public static class NoPaciente {
    private Paciente paciente;
    private NoPaciente proximo;

    public NoPaciente(Paciente p){
        this.paciente = p;
        this.proximo = null;
    }

    public Paciente getPaciente()
    {return paciente; }
    public NoPaciente getProximo()
    {return proximo; }
    public void setProximo(NoPaciente proximo) 
    { this.proximo = proximo; }
}

public static class ListaPacientes {
    private NoPaciente inicio;
    private int tamanho;

    public ListaPacientes() {
        this.inicio = null;
        this.tamanho = 0;
    }

    public boolean vazia() {
        return inicio == null;
    }

    public NoPaciente getInicio() {
        return inicio;
    }

    public int getTamanho() {
        return tamanho;
    }

    public void adicionar(Paciente p) {
        NoPaciente novo = new NoPaciente(p);
        if (inicio == null) {
            inicio = novo;
        } else {
            NoPaciente atual = inicio;
            while (atual.getProximo() != null) {
                atual = atual.getProximo();
            }
            atual.setProximo(novo);
        }
        tamanho++;
    }

    public boolean removerPorId(String id){
        if (vazia()){
        return false;
        }
        if (inicio.getPaciente().getId().equals(id)) {
            inicio = inicio.getProximo();
            tamanho--;
            return true;
        }

        NoPaciente atual = inicio;
        while (atual.getProximo() != null && !atual.getProximo().getPaciente().getId().equals(id)) {
            atual = atual.getProximo();
        }

        if (atual.getProximo() != null) {
            atual.setProximo(atual.getProximo().getProximo());
            tamanho--;
            return true;
        }

        return false;
    }

    public Paciente removerPrimeiro(){

        if(this.vazia()){
            return null;
        }

        Paciente primeiro = inicio.getPaciente();

        this.inicio = this.inicio.getProximo(); 
        tamanho--;

        return primeiro;   
    }

    public Paciente[] listaPacientesParaArray() {
        Paciente[] array = new Paciente[tamanho];
        NoPaciente atual = inicio;

        int indice = 0;

        while (atual != null) {
            array[indice] = atual.getPaciente();
            atual = atual.getProximo();
            indice++;
        }

        return array;
    }
}
