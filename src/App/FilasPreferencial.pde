public static class FilasPreferencial {

    private static ListaPacientes[] filas = new ListaPacientes[2];
    public static int preferenciaisAtendidos = 0;

    public final static int PREFERENCIAL = 1;
    public final static int NORMAL = 0;
    public final static int LIMITE_ALTERNANCIA = 2;


    public static void preencheFilas() {
        preferenciaisAtendidos = 0;
        for(int i = 0; i < filas.length; i++) {
            filas[i] = new ListaPacientes();
        }
    }

    public static void adicionarPaciente(Paciente p)  {  
        filas[(p.getPreferencial() ? PREFERENCIAL : NORMAL)].adicionar(p);
    }

    public static Paciente chamarProximo() {

        if(!(filas[PREFERENCIAL].vazia()) && preferenciaisAtendidos < LIMITE_ALTERNANCIA) {
            preferenciaisAtendidos++;
            return filas[PREFERENCIAL].removerPrimeiro();
        }

        Paciente paciente = filas[NORMAL].removerPrimeiro(); 
        
        if(paciente != null) {
            preferenciaisAtendidos = 0;
            return paciente;
        }

        return filas[PREFERENCIAL].removerPrimeiro();
    }
}