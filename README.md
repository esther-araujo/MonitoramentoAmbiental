<div id="inicio">
    <h1 id="titulo" align="center">Problema 3 - MI Sistemas Digitais</h1>
	<p id="descricao" align="justify">Protótipo de um sistema para monitoramento ambiental, incluindo todo o tratamento e controle de sensores analógicos e digitais, bem como uma IHM (Interface Homem-Máquina) para apresentação das informações, incluindo históricos dos dados. O protótipo foi desenvolvido num SBC (Raspberry Pi Zero) que mede temperatura, umidade, pressão atmosférica e luminosidade. A IHM apresenta, em tempo real, as leituras atuais e também permite a visualização do histórico com as 10 últimas medições de cada sensor. 
</P>
<p id="descricao" align="justify">O sistema deve permite o ajuste local e remoto do intervalo de tempo que serão realizadas as medições. No caso da configuração e do monitoramento remoto, é utilizada uma aplicação (Desktop e Android). A aplicação e o SBC se comunicam através do protocolo MQTT.</p>
</div>

<!--ts-->
   * [Sobre](#Sobre)
   * [Instalação](#instalacao)
   * [Como usar](#como-usar)
      * [Pre Requisitos](#pre-requisitos)
      * [IHM - Interface Homem Máquina](#ihm)
      * [Aplicativo](#aplicativo)
   * [Testes](#testes)
<!--te-->

## Como usar
### Pré Requisitos
### Aplicativo
<h3><p><b>Interação com usuário:</b></p></h3>
	<p align="justify"> 
       Na Aba de Configurações, é necessário realizar a autenticação com o Broker
    <p> 
<h1 align="center">
  <img alt="" title="#ConfigBroker" src="./assets/APP/ConfigBroker.png" />
</h1>

<p align="justify"> 
       Dessa forma, será possível monitorar as medições na aba dos Sensores. Nessa página também é possível configurar o tempo de medição.
    <p> 

<h1 align="center">
  <img alt="" title="#Sensores" src="./assets/APP/Sensores.png" />
</h1>

<p align="justify"> 
       Navegando na aba Histórico, será possível verificar as últimas 10 medições de cada sensor na tela.
    <p> 

<h1 align="center">
  <img alt="" title="#Hist" src="./assets/APP/Hist.png" />
</h1>

### Smartphone
<h1 align="center">
  <img alt="" width="20%" height="auto" title="#Hist" src="./assets/APP/Conf.png" />
    <img alt="" width="20%" height="auto" title="#Hist" src="./assets/APP/Sens.png" />
  <img alt=""  width="20%" height="auto" title="#Hist" src="./assets/APP/HistS.png" />

</h1>
 