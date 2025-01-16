<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Logon.aspx.cs" Inherits="DX_WebTemplate.Logon" %>

<!DOCTYPE html>
   <style>
           body {
      background: url('../Content/Images/zig-zag.svg') no-repeat center center fixed; 
      /* Set the background image to cover the whole page */
      background-size: cover; 
    }

       .container {
           display: flex;
           flex-direction: column;
           justify-content: center;
           align-items: center;
       }
    </style>

<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="Jessy Pimentera">
    <title>Anflo Group Apps (AGA)</title>
    <link rel="icon" type="image/x-icon" href="../Content/Images/favicon.ico">

    <!-- Bootstrap core CSS -->
<link href="../styles/bootstrap.min.css" rel="stylesheet">

    <style>
      .bd-placeholder-img {
        font-size: 1.125rem;
        text-anchor: middle;
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
        user-select: none;
      }

      @media (min-width: 768px) {
        .bd-placeholder-img-lg {
          font-size: 3.5rem;
        }
      }
    </style>

    
    <!-- Custom styles for this template -->
    <link href="styles/signin.css" rel="stylesheet">
  </head>
  <body class="text-center">
    
<form class="form-signin" runat="server">
  <img class="mb-4" src="../Content/Images/Anflocor_LOGO_WHITE_FILL.png" alt="" width="150" height="150">
    
<div class="alert alert-danger" role="alert" runat="server" id="invalidAlert" visible="false">
  Tsk. Please check Username and/or Password!
</div>
<div class="alert alert-success" role="alert" runat="server" id="validAlert" visible="false">
 User successfully found!
</div>
  <%--<h1 class="h3 mb-3 font-weight-normal">Please sign in</h1>--%>

  <%--<label for="inputUserName" class="sr-only">Username</label>--%>
  <input type="text" id="inputUserName" runat="server" class="form-control" placeholder="Username" required autofocus>
  <%--<label for="inputPassword" class="sr-only">Password</label>--%>
  <input type="password" id="inputPassword" runat="server" class="form-control" placeholder="Password" required style="margin-top: 10px">


  <%--<button id="btnLogin" class="btn btn-lg btn-primary btn-block" runat="server" onclick="btnLogin_Click">Sign in</button>--%>
    <dx:ASPxButton ID="formLogin_E2" runat="server" Font-Bold="True" OnClick="btnLogin_Click" Text="LOG IN" Width="100%"
        class="btn btn-lg btn-primary btn-block" Theme="MaterialCompact">
    </dx:ASPxButton>


  <p class="mt-5 mb-3 text-muted">&copy; Anflo Group of Companies</p>
</form>


    
  </body>
</html>
