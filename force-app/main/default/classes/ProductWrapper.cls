public class ProductWrapper {
        @AuraEnabled
        public String categoria{get;set;}
        @AuraEnabled
        public String codigoProducto{get;set;}
        @AuraEnabled
        public String codigoSku{get;set;}
        @AuraEnabled
        public String codigoCliente{get;set;}
        @AuraEnabled
        public String nombre{get;set;}
        @AuraEnabled
        public String descripcion{get;set;}

        public ProductWrapper(String categoria, String codigoProducto, String codigoSku, 
                            String codigoCliente, String nombre, String descripcion) {
            this.categoria = categoria;
            this.codigoProducto = codigoProducto;
            this.codigoSku = codigoSku;
            this.codigoCliente = codigoCliente;
            this.nombre = nombre;
            this.descripcion = descripcion;
        }
    }