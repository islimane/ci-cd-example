/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Test class from GL_WS_Order_Exposed

History:
<Date>                  <Author>                <Change Description>
21/06/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest(SeeAllData=true) //The Order Summary Object only admits seeAllData = true, cannot be created by Test
private class GL_WS_Order_Exposed_TEST {
    
    @isTest
    static void manageOrdersTest() {
        Account acc = [SELECT Id,ID_Lion__c, GL_AccountManager__r.CodeInitials__c, GL_AccountManager__r.Email FROM Account WHERE ID_Lion__c = '15-DUMMY;02-DUMMY;' LIMIT 2];
        List<Product2> prod = [SELECT Id, ID_Lion__c, External_Id__c FROM Product2 WHERE ID_Lion__c != null AND Material__c = false LIMIT 2];
        Shipping_Customer_Company__c scc = [SELECT Id, Account__r.Name, Delivery_Company__r.Delivery_Company_Code__c, Contact_Point_Address__r.ID_Lion__c 
                                            FROM Shipping_Customer_Company__c 
                                            WHERE Account__r.Id = :acc.Id AND Contact_Point_Address__r.ID_Lion__c LIKE '15-DUMMY-2' AND Delivery_Company__r.Delivery_Company_Code__c =: 113
                                            LIMIT 1];
        String idLion = acc.ID_Lion__c;
        String idLionOK = idLion.split(';')[0].removeStart('15-');
        String idLionCPA =scc.Contact_Point_Address__r.ID_Lion__c;
        String idLionCPAOK =idLionCPA.split(';')[0].removeStart('15-DUMMY-');
        
        GL_WS_Order_Structure.DoOrder pedidos = new GL_WS_Order_Structure.DoOrder();
        List<GL_WS_Order_Structure.Pedido> pedList = new List<GL_WS_Order_Structure.Pedido>();
        GL_WS_Order_Structure.Pedido ped = new GL_WS_Order_Structure.Pedido();
        GL_WS_Order_Structure.Cabecera cab = new GL_WS_Order_Structure.Cabecera();
        cab.insorupdorget = 'I';
        cab.acumularportes = 'S';
        cab.albarasinpre = 'S';
        cab.claiva = '21,2';
        cab.coclie = idLionOK;
        cab.codagt = String.valueOf(scc.Delivery_Company__r.Delivery_Company_Code__c);
        cab.codmnd = '1';
        cab.codpor = 'P';
        cab.cofenv = '3';
        cab.covend = acc.GL_AccountManager__r.CodeInitials__c;
        cab.dtoesp = '3,8';
        cab.email = acc.GL_AccountManager__r.Email;
        cab.empresa = '15';
        cab.estado = 'S';
        cab.fechaconf = '01012022';
        cab.fecped = '01012022';
        cab.fpago = 'Forma Pago Esp';
        cab.fpagoa = 'Forma Pago Ale';
        cab.fpagof = 'Forma Pago Fra';
        cab.fpagoi = 'Forma Pago Ing';
        cab.fpagop = 'Forma Pago Por';
        cab.kilacu = '20';
        cab.npclie = 'Test Order Naming';
        cab.numconf = '0';
        cab.numdir = idLionCPAOK;
        cab.pedcli = GL_WS_Utils.generateRandomString(9);
        cab.poremb = '30,4';
        cab.extid = 'LionIdForTesting';
        
        List<GL_WS_Order_Structure.Lineas> linLst = new List<GL_WS_Order_Structure.Lineas>();
        GL_WS_Order_Structure.Lineas lin1 = new GL_WS_Order_Structure.Lineas();
        lin1.canped = '100';
        lin1.canpes = '50';
        lin1.codart = prod[0].ID_Lion__c;
        lin1.descue = '2';
        lin1.descue2 = '3';
        lin1.estado = 'S';
        lin1.extidofe = '';
        lin1.extidofelin = '';
        lin1.fecent = '02022022';
        lin1.fecentw = '5';
        lin1.nlinea = '1';
        lin1.precio = '1000';
        lin1.txtpre = 'C';
        lin1.unimed = 'U';
        lin1.extidlin = 'LionIdForOrderLineTest1';
        
        GL_WS_Order_Structure.Lineas lin2 = new GL_WS_Order_Structure.Lineas();
        lin2.canped = '100';
        lin2.canpes = '50';
        lin2.codart = prod[1].ID_Lion__c;
        lin2.descue = '2';
        lin2.descue2 = '3';
        lin2.estado = 'S';
        lin2.extidofe = '';
        lin2.extidofelin = '';
        lin2.fecent = '02022022';
        lin2.fecentw = '5';
        lin2.nlinea = '1';
        lin2.precio = '1000';
        lin2.txtpre = 'M';
        lin2.unimed = 'U';
        lin2.extidlin = 'LionIdForOrderLineTest2';
        
        linLst.add(lin1);
        linLst.add(lin2);
        ped.cabecera = cab;
        ped.lineas = linLst;
        pedList.add(ped);
        pedidos.pedido = pedList;
        
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Test.startTest();
        GL_WS_Order_Structure.PedidoResponse response = GL_WS_Order_Exposed.manageOrders(pedidos);
        Test.stopTest();
        System.assertEquals(true, response.error.errorType == null);
        System.assertEquals(true, response.pedidos[0].cabecera.pedcli != null);
    }
    
    @isTest
    static void manageOrdersUpdateTest() {
        Account acc = [SELECT Id, ID_Lion__c, GL_AccountManager__r.CodeInitials__c, GL_AccountManager__r.Email FROM Account WHERE ID_Lion__c = '15-30222;02-123262;' LIMIT 1];
        Product2 prod = [SELECT Id, ID_Lion__c FROM Product2 WHERE ID_Lion__c != null LIMIT 1];
        Shipping_Customer_Company__c scc = [SELECT Id, Account__r.Name, Delivery_Company__r.Delivery_Company_Code__c, Contact_Point_Address__r.ID_Lion__c FROM Shipping_Customer_Company__c WHERE Account__r.Id = :acc.Id AND Delivery_Company__r.Delivery_Company_Code__c = :321 LIMIT 1];
        OrderItemSummary ois = [SELECT Id, External_Id__c, OrderSummary.External_Id__c, OrderSummary.OriginalOrderId  FROM OrderItemSummary WHERE OrderSummary.AccountId = :acc.Id AND Type = 'Order Product' LIMIT 1];
        String ordId = ois.OrderSummary.OriginalOrderId;
        OrderDeliveryGroup odg = [SELECT Id, OrderDeliveryMethodId FROM OrderDeliveryGroup WHERE OrderId = :ordId LIMIT 1];
        OrderDeliveryMethod odm = [SELECT Id FROM OrderDeliveryMethod WHERE Id = :odg.OrderDeliveryMethodId LIMIT 1];
        
        GL_WS_Order_Structure.DoOrder pedidos = new GL_WS_Order_Structure.DoOrder();
        List<GL_WS_Order_Structure.Pedido> pedList = new List<GL_WS_Order_Structure.Pedido>();
        GL_WS_Order_Structure.Pedido ped = new GL_WS_Order_Structure.Pedido();
        GL_WS_Order_Structure.Cabecera cab = new GL_WS_Order_Structure.Cabecera();
        
        String idLion = acc.ID_Lion__c;
        String idLionOK = idLion.split(';')[0].removeStart('15-');
        String idLionCPA =scc.Contact_Point_Address__r.ID_Lion__c;
        String idLionCPAOK =idLionCPA.removeStart('15-');
        
        cab.insorupdorget = 'U';
        cab.acumularportes = 'S';
        cab.albarasinpre = 'S';
        cab.claiva = '21,2';
        cab.coclie = idLionOK;
        cab.codagt = String.valueOf(scc.Delivery_Company__r.Delivery_Company_Code__c);
        cab.codmnd = '1';
        cab.codpor = 'P';
        cab.cofenv = '3';
        cab.covend = acc.GL_AccountManager__r.CodeInitials__c;
        cab.dtoesp = '3,8';
        cab.email = acc.GL_AccountManager__r.Email;
        cab.empresa = '15';
        cab.estado = 'S';
        cab.fechaconf = '01012022';
        cab.fecped = '01012022';
        cab.fpago = 'Forma Pago Esp';
        cab.fpagoa = 'Forma Pago Ale';
        cab.fpagof = 'Forma Pago Fra';
        cab.fpagoi = 'Forma Pago Ing';
        cab.fpagop = 'Forma Pago Por';
        cab.kilacu = '20';
        cab.npclie = 'Test Order Naming';
        cab.numconf = '0';
        cab.numdir = idLionCPAOK;
        cab.pedcli = '123456789';
        cab.poremb = '30,4';
        cab.extid = ois.OrderSummary.External_Id__c;
        
        List<GL_WS_Order_Structure.Lineas> linLst = new List<GL_WS_Order_Structure.Lineas>();
        GL_WS_Order_Structure.Lineas lin = new GL_WS_Order_Structure.Lineas();
        lin.canped = '200';
        lin.canpes = '50';
        lin.codart = prod.ID_Lion__c;
        lin.descue = '2';
        lin.descue2 = '3';
        lin.estado = 'S';
        lin.extidofe = '';
        lin.extidofelin = '';
        lin.fecent = '02022022';
        lin.fecentw = '5';
        lin.nlinea = '1';
        lin.precio = '1000';
        lin.txtpre = 'M';
        lin.unimed = 'U';
        lin.extidlin = ois.External_Id__c;
        
        linLst.add(lin);
        ped.cabecera = cab;
        ped.lineas = linLst;
        pedList.add(ped);
        pedidos.pedido = pedList;
        
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Test.startTest();
        GL_WS_Order_Structure.PedidoResponse response = GL_WS_Order_Exposed.manageOrders(pedidos);
        Test.stopTest();
        
        System.assertEquals(true, response.error.errorType == null);
        System.assertEquals(true, response.pedidos[0].cabecera.extid != null);
    }
    
}