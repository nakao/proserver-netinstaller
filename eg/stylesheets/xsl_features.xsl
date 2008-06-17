<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html" indent="yes"/>
  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head><style type="text/css">html,body{background:#ffc;font-family:helvetica,arial,sans-serif;font-size:0.8em}thead{background:#700;color:#fff}thead th{margin:0;padding:2px}a{color:#a00}a:hover{color:#aaa}.tr1{background:#ffd}.tr2{background:#ffb}tr{vertical-align:top}</style>
<script type="text/javascript"><![CDATA[
addEvent(window,"load",zi);
function zi(){if(!document.getElementsByTagName)return;var ts=document.getElementsByTagName("table");for(var i=0;i!=ts.length;i++){t=ts[i];if(t){if(((' '+t.className+' ').indexOf("z")!=-1))z(t);}}}
function z(t){var tr=1;for(var i=0;i!=t.rows.length;i++){var r=t.rows[i];var p=r.parentNode.tagName.toLowerCase();if(p!='thead'){if(p!='tfoot'){r.className='tr'+tr;tr=1+!(tr-1);}}}}
function addEvent(e,t,f,c){/*Scott Andrew*/if(e.addEventListener){e.addEventListener(t,f,c);return true;}else if(e.attachEvent){var r=e.attachEvent("on"+t,f);return r;}}
function hideColumn(c){var t=document.getElementById('data');var trs=t.getElementsByTagName('tr');for(var i=0;i!=trs.length;i++){var tds=trs[i].getElementsByTagName('td');if(tds.length!=0)tds[c].style.display="none";var ths=trs[i].getElementsByTagName('th');if(ths.length!=0)ths[c].style.display="none";}}
]]></script><title>ProServer: Features for <xsl:value-of select="/DASGFF/GFF/@href"/></title></head>
      <body>
        <div id="header"><h4>ProServer: Features for <xsl:value-of select="/DASGFF/GFF/@href"/></h4></div>
        <div id="mainbody">
          <table class="z" id="data">
            <thead><tr>
              <th onclick="hideColumn(0);">Label</th>
              <th onclick="hideColumn(1);">Segment</th>
              <th onclick="hideColumn(2);">Start</th>
              <th onclick="hideColumn(3);">End</th>
              <th onclick="hideColumn(4);">Orientation</th>
              <th onclick="hideColumn(5);">Type</th>
              <th onclick="hideColumn(6);">Notes</th>
              <th onclick="hideColumn(7);">Link</th>
            </tr></thead><tbody>
            <xsl:apply-templates select="/DASGFF/GFF/SEGMENT"/>
            </tbody>
          </table>
        </div>
      </body>
    </html>
  </xsl:template>
  <xsl:template match="SEGMENT">
    <xsl:for-each select="FEATURE">
      <xsl:sort select="@id"/>
      <tr>
        <td><xsl:value-of select="@label"/></td>
        <td><xsl:value-of select="../@id"/></td>
        <td><xsl:value-of select="START"/></td>
        <td><xsl:value-of select="END"/></td>
        <td><xsl:value-of select="ORIENTATION"/></td>
        <td><xsl:value-of select="TYPE"/></td>
        <td><xsl:apply-templates select="NOTE"/></td>
        <td><xsl:if test="LINK"><xsl:apply-templates select="LINK"/></xsl:if></td>
      </tr>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="NOTE">
    <xsl:value-of select="."/>
    <xsl:if test="position()!=last()"><br/></xsl:if>
  </xsl:template>
  <xsl:template match="LINK">
    [<a><xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute><xsl:value-of select="."/></a>]
  </xsl:template>
</xsl:stylesheet>
