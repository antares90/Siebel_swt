<?xml version="1.0" encoding="utf-16"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html" media-type="text/html"></xsl:output>

  <!--  ====================== Root Document Processing ======================== -->
  <xsl:template match="/">
    <xsl:apply-templates select="//APPLICATION/SCREEN/VIEW/APPLET"></xsl:apply-templates>
  </xsl:template>
  
  <!--  ============================ View Processing =========================== -->
  <xsl:template match="APPLET">
    <html>
      <head>
        <meta http-equiv="cache-control" content="no-cache"></meta>
      </head>

      <body>
        <!-- APPLET TITLE, context text, Search and New in Table 1  -->
        <xsl:variable name="strTitle">
          <xsl:choose>
            <xsl:when test="string-length(normalize-space(//CALENDAR/@TITLE))">
              <xsl:variable name="strCalTitle">
                <xsl:value-of select="//VIEW/@TITLE"/>
              </xsl:variable>
              <xsl:variable name="strCalDate">
                <xsl:value-of select="//CALENDAR/@TITLE"/>
              </xsl:variable>
              <xsl:value-of select="concat($strCalTitle, ' : ', $strCalDate)"/>
            </xsl:when>
            <xsl:when test="string-length(normalize-space(CONTROL[@ID='1']))">
              <xsl:value-of select="CONTROL[@ID='1']"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="strViewTitle">
          <xsl:choose>
            <xsl:when test="CONTROL[@ID&gt;1 and @ID&lt;11 and @HTML_TYPE='Text']">
              <xsl:variable name="strSubTitle">
                <xsl:apply-templates select="CONTROL[@ID&gt;1 and @ID&lt;11 and @HTML_TYPE='Text']"/>
              </xsl:variable>
              <xsl:value-of select="concat($strTitle, ' : ', $strSubTitle)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$strTitle"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <table bgcolor="#333399" border="0" width="100%" cellpadding="2" cellspacing="0">
          <tr>
            <td align="center" valine="middle" width="100%">
              <font face="Arial" color="#FFFFFF">
                <b>
                  <xsl:value-of select="$strViewTitle"/>
                </b>
              </font>
            </td>
          </tr>
        </table>

        <table border="0" width="100%" cellspacing="0" cellpadding="0" bgcolor="#999999">
          <tr>
            <td bgcolor="#FFFFFF" width="100%" height="1"></td>
          </tr>
        </table>

        <!--  Error message  -->
        <xsl:if test="string-length(//ERROR)>0">
          <table border="0" width="100%" cellspacing="0" cellpadding="0" bgcolor="#9999CC">
            <tr>
              <td bgcolor="#000066" width="100%" height="2"></td>
            </tr>
          </table>
          <table border="0" width="100%" cellspacing="0" cellpadding="3" bgcolor="#FFFF77">
            <tr>
              <td bgcolor="#FFFF77">
                <font face="Arial" color="#000000"> 
                  <xsl:value-of select="//ERROR"></xsl:value-of>
                  <br></br>
                </font>
              </td>
            </tr>
          </table>
        </xsl:if>

        <!--   List in Table 2  -->
        <table border="0" width="100%" cellspacing="0" cellpadding="0" bgcolor="#9999CC">
          <tr>
            <td bgcolor="#000066" width="100%" height="2"></td>
          </tr>
        </table>

        <table border="0" width="100%" cellspacing="0" cellpadding="3" bgcolor="#9999CC">
          <td>
            <table align="left" border="0" cellspacing="0" cellpadding="0" bgcolor="#9999CC">
              <tr>
                <xsl:if test="CONTROL[normalize-space(ANCHOR/CMD/ARG[@NAME='M']/text())='NewRecord' or normalize-space(ANCHOR/CMD/ARG[@NAME='M']/text())='NewQuery']">
                  <td align="left">
                    <xsl:for-each select="CONTROL[ANCHOR/CMD/ARG[@NAME='M']]">
                      <xsl:if test="normalize-space(ANCHOR/CMD/ARG[@NAME='M']/text())='NewQuery' and @NAME!='Go to date'">
                        <xsl:call-template name="build_image_link">
                          <xsl:with-param name="fileName">images/icon_search.gif</xsl:with-param>
                          <xsl:with-param name="alt">Search</xsl:with-param>
                        </xsl:call-template>
                      </xsl:if>
                      <xsl:if test="normalize-space(ANCHOR/CMD/ARG[@NAME='M']/text())='NewRecord'">
                        <xsl:call-template name="build_image_link">
                          <xsl:with-param name="fileName">images/swls_new.gif</xsl:with-param>
                          <xsl:with-param name="alt">New</xsl:with-param>
                        </xsl:call-template>
                      </xsl:if>
                    </xsl:for-each>
                  </td>
                </xsl:if>
              </tr>
            </table>
          </td>

          <td>
            <table align="right" border="0" cellspacing="0" cellpadding="0" bgcolor="#9999CC">
              <tr>
                <td align="right" colspan="3">
                  <!-- previous link-->
                  <xsl:call-template name="build_previous_link"/>
                  <xsl:if test="string-length(@ROW_COUNTER)>0">
                    <font face="Arial" size="2" color="#FFFFFF">
                      <xsl:value-of select="@ROW_COUNTER"></xsl:value-of>
                    </font>
                  </xsl:if>
                  <xsl:call-template name="build_more_link"/>
                </td>
              </tr>
            </table>
          </td>
        </table>

        <table border="0" width="100%" cellspacing="0" cellpadding="0" bgcolor="#9999CC">
          <tr>
            <td bgcolor="#000066" width="100%" height="1"></td>
          </tr>
        </table>

        <table border="0" width="100%" cellspacing="0" cellpadding="3" bgcolor="#EEFFFF">
          <xsl:apply-templates select="LIST" />
        </table>

        <!-- Shows Alert Message (i.e. No Records Found -->
        <xsl:if test="string-length(//ALERT)>0">
          <table border="0" width="100%" cellspacing="0" cellpadding="3" bgcolor="#EEFFFF">
            <tr>
              <td bgcolor="#EEFFFF">
                  <font face="Arial" color="#000000"> 
                    <xsl:value-of select="//ALERT"></xsl:value-of>
                  </font>
              </td>
            </tr>
          </table>
        </xsl:if>

        <!--   Other links in Table 3-->
        <table border="0" width="100%" cellspacing="0" cellpadding="0" bgcolor="#9999CC">
          <tr>
            <td bgcolor="#333399" width="100%" height="1"></td>
          </tr>
        </table>
        <table border="0" width="100%" cellspacing="0" cellpadding="3" bgcolor="#9999CC">
          <xsl:apply-templates select="CONTROL[@ID>=41 and @HTML_TYPE='Link']" />
        </table>
        <table border="0" width="100%" cellspacing="0" cellpadding="0" bgcolor="#9999CC">
          <tr>
            <td bgcolor="#333399" width="100%" height="2"></td>
          </tr>
        </table>
      </body>
    </html>
  </xsl:template>

  <!--  ======================================== Control and Link Processing ====================== -->
  <xsl:template match="CONTROL[@ID&gt;1 and @ID&lt;11 and @HTML_TYPE='Text']">
    <xsl:value-of select="normalize-space(text())"></xsl:value-of>
  </xsl:template>

  <xsl:template match="CONTROL[@ID>=41 and @HTML_TYPE='Link']">
    <xsl:choose>
      <xsl:when test="normalize-space(ANCHOR/CMD/ARG[@NAME='M']/text())='NewRecord'"></xsl:when>
      <xsl:otherwise>
        <xsl:variable name="thePosition">
          <xsl:choose>
            <xsl:when test="preceding-sibling::CONTROL[normalize-space(ANCHOR/CMD/ARG[@NAME='M'])='NewRecord']">
              <xsl:value-of select="position()+-1"></xsl:value-of>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="position()"></xsl:value-of>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="@NAME='Main Menu' or $thePosition mod 2 != 0">
          <tr>
            <td align="left" valign="top">
              <font face="Arial" size="2">
                <xsl:call-template name="build_link_or_home_button"></xsl:call-template>
              </font>
            </td>
            <td align="right">
              <font face="Arial" size="2">
                <xsl:choose>
                  <xsl:when test="normalize-space(following-sibling::CONTROL[1]/ANCHOR/CMD/ARG[@NAME='M']/text())='NewRecord'">
                    <xsl:if test="following-sibling::CONTROL[2]/@NAME!='Main Menu'">
                      <xsl:call-template name="build_next_next_link"></xsl:call-template>
                    </xsl:if>
                  </xsl:when>
                  <xsl:when test="following-sibling::CONTROL[1]/@NAME!='Main Menu'">
                    <xsl:call-template name="build_next_link"></xsl:call-template>
                  </xsl:when>
                  <xsl:when test="@NAME='Main Menu'">
                    <!-- Thread Pick List -->
                    <xsl:if test="//NAVIGATION_ELEMENTS/THREAD_BAR/THREAD">
                      <xsl:apply-templates select="//NAVIGATION_ELEMENTS/THREAD_BAR"></xsl:apply-templates>
                    </xsl:if>
                  </xsl:when>
                </xsl:choose>
              </font>
            </td>
          </tr>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build_image_link">
    <xsl:param name="fileName"/>
    <xsl:param name="alt"/>
    <xsl:variable name="link">
      <xsl:apply-templates select="ANCHOR"></xsl:apply-templates>
    </xsl:variable>
    <xsl:element name="A">
      <xsl:attribute name="HREF">
        <xsl:value-of select="$link"></xsl:value-of>
      </xsl:attribute>
      <img border="0" src="{$fileName}" alt="{$alt}"></img>
    </xsl:element>
  </xsl:template>

  <xsl:template name="build_link_or_home_button">
    <xsl:choose>
      <xsl:when test="@NAME='Main Menu'">
        <xsl:call-template name="build_home_button"></xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="build_simple_link"></xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build_simple_link">
    <xsl:variable name="link">
      <xsl:apply-templates select="ANCHOR"></xsl:apply-templates>
    </xsl:variable>
    <xsl:element name="A">
      <xsl:attribute name="HREF">
        <xsl:value-of select="$link"></xsl:value-of>
      </xsl:attribute>
      <xsl:value-of select="normalize-space(@CAPTION)"></xsl:value-of>
    </xsl:element>
  </xsl:template>

  <xsl:template name="build_next_link">
    <xsl:if test="following-sibling::CONTROL[1]/@HTML_TYPE='Link'">
      <xsl:variable name="link">
        <xsl:apply-templates select="following-sibling::CONTROL[1]/ANCHOR"></xsl:apply-templates>
      </xsl:variable>
      <xsl:element name="A">
        <xsl:attribute name="HREF">
          <xsl:value-of select="$link"></xsl:value-of>
        </xsl:attribute>
        <xsl:value-of select="normalize-space(following-sibling::CONTROL[1]/@CAPTION)"></xsl:value-of>
      </xsl:element>
      <br></br>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build_next_next_link">
    <xsl:if test="following-sibling::CONTROL[2]/@HTML_TYPE='Link'">
      <xsl:variable name="link">
        <xsl:apply-templates select="following-sibling::CONTROL[2]/ANCHOR"></xsl:apply-templates>
      </xsl:variable>
      <xsl:element name="A">
        <xsl:attribute name="HREF">
          <xsl:value-of select="$link"></xsl:value-of>
        </xsl:attribute>
        <xsl:value-of select="normalize-space(following-sibling::CONTROL[2]/@CAPTION)"></xsl:value-of>
      </xsl:element>
      <br></br>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build_home_button">
    <xsl:variable name="link">
      <xsl:apply-templates select="ANCHOR"></xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="preLink">
      <xsl:text>document.location.href='</xsl:text>
    </xsl:variable>
    <xsl:variable name="postLink">
      <xsl:text>'</xsl:text>
    </xsl:variable>
    <xsl:element name="Input">
      <xsl:attribute name="Type">
        <xsl:text>button</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="Value">
        <xsl:value-of select="@CAPTION"></xsl:value-of>
      </xsl:attribute>
      <xsl:attribute name="Name">
        <xsl:value-of select="@NAME"></xsl:value-of>
      </xsl:attribute>
      <xsl:attribute name="onclick">
        <xsl:value-of select="concat(normalize-space($preLink), normalize-space($link), normalize-space($postLink))"></xsl:value-of>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template name="build_previous_link">
    <xsl:for-each select="LIST/RS_HEADER/METHOD">
      <xsl:if test="normalize-space(ANCHOR/CMD/ARG[@NAME='M']/text())='GotoPreviousSet'">
        <xsl:variable name="caption">
          <xsl:value-of select="normalize-space(@CAPTION)"/>
         </xsl:variable>
        <xsl:element name="a">
	  <xsl:attribute name="href">
            <xsl:apply-templates select="ANCHOR"/>
	  </xsl:attribute>
	  <img  border="0" align="bottom" src="images/message_bar_prv_.gif" alt="{$caption}"></img>
        </xsl:element>
      </xsl:if>
    </xsl:for-each>
  </xsl:template> 

  <xsl:template name="build_more_link">
    <xsl:for-each select="LIST/RS_HEADER/METHOD">
      <xsl:if test="normalize-space(ANCHOR/CMD/ARG[@NAME='M']/text())='GotoNextSet' or 
                      normalize-space(ANCHOR/CMD/ARG[@NAME='M']/text())='FindBranch'">
        <xsl:variable name="caption">
          <xsl:value-of select="normalize-space(@CAPTION)"/>
        </xsl:variable>
        <xsl:element name="a">
	  <xsl:attribute name="href">
	    <xsl:apply-templates select="ANCHOR"/>
	  </xsl:attribute>
	  <img  border="0" align="bottom" src="images/message_bar_nxt_.gif" alt="{$caption}"></img>
	</xsl:element>
      </xsl:if>
    </xsl:for-each>
  </xsl:template> 


  <!--  Thread Pick List  -->
  <xsl:template match="//NAVIGATION_ELEMENTS/THREAD_BAR">
    <xsl:element name="Form">
      <xsl:attribute name="METHOD">
        <xsl:text>POST</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="Name">
        <xsl:text>thread</xsl:text>
      </xsl:attribute>
      <xsl:variable name="separator">
        <xsl:text>:</xsl:text>
      </xsl:variable>
      <xsl:if test="THREAD/ANCHOR">
        <xsl:element name="Select">
          <xsl:attribute name="Name">
            <xsl:text>threadlink</xsl:text>
          </xsl:attribute>
          <xsl:for-each select="THREAD">
            <xsl:if test="ANCHOR">
              <xsl:element name="Option">
                <xsl:variable name="link">
                  <xsl:apply-templates select="ANCHOR"></xsl:apply-templates>
                </xsl:variable>
                <xsl:attribute name="value">
                  <xsl:value-of select="normalize-space($link)"></xsl:value-of>
                </xsl:attribute>
                <xsl:variable name="threadTitle">
                  <xsl:value-of select="normalize-space(text())"></xsl:value-of>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="string-length($threadTitle)>15">
                    <xsl:variable name="subThreadTitle">
                      <xsl:value-of select="substring($threadTitle,1,15)"></xsl:value-of>
                    </xsl:variable>
                    <xsl:value-of select="concat(normalize-space(@TITLE),normalize-space($separator),normalize-space($subThreadTitle))"></xsl:value-of>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat(normalize-space(@TITLE),normalize-space($separator),normalize-space($threadTitle))"></xsl:value-of>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:element>
            </xsl:if>
          </xsl:for-each>
        </xsl:element>

        <xsl:element name="Input">
          <xsl:attribute name="Type">
            <xsl:text>button</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="Value">
            <xsl:text>Go</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="onclick">
            <xsl:text>document.location.href=document.thread.threadlink.options[document.thread.threadlink.selectedIndex].value</xsl:text>
          </xsl:attribute>
        </xsl:element>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template name="build_thread_link">
    <xsl:choose>
      <xsl:when test="ANCHOR">
        <xsl:variable name="link">
          <xsl:apply-templates select="ANCHOR"></xsl:apply-templates>
        </xsl:variable>
        <xsl:element name="A">
          <xsl:attribute name="HREF">
            <xsl:value-of select="$link"></xsl:value-of>
          </xsl:attribute>
          <xsl:value-of select="normalize-space(@TITLE)"></xsl:value-of>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space(@TITLE)"></xsl:value-of>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!--  ============================ List processing ========================== -->
  <xsl:template match="LIST">
    <xsl:variable name="link">
      <xsl:apply-templates select="RS_HEADER/METHOD[@NAME='Drilldown'][1]"></xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="link-prefix">
      <xsl:value-of select="substring-before($link,'R=')"></xsl:value-of>
    </xsl:variable>
    <xsl:variable name="link-suffix">
      <xsl:value-of select="substring-after($link,'R=')"></xsl:value-of>
    </xsl:variable>
    
    <xsl:for-each select="RS_DATA/ROW">
      <xsl:variable name="rowid">
        <xsl:call-template name="ENCODE_ARG">
          <xsl:with-param name="encode_string" select="@ROWID"></xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="numField">
        <xsl:value-of select="count(FIELD) + count(CONTROL)"></xsl:value-of>
      </xsl:variable>

      <!--  loop through each field and control in the Row  -->
      <xsl:choose>
        <!-- More than 3 Column Field and Control -->
        <xsl:when test="$numField &gt; 3">
          <tr>
            <td align="left" colspan="2">
              <font face="Arial" size="2">
                <xsl:value-of select="normalize-space(FIELD)"></xsl:value-of>
              </font>
            </td>
          </tr>
          <xsl:for-each select="CONTROL">
            <xsl:choose>
              <xsl:when test="@ID">
                <tr>
                  <td align="left">
                    <font face="Arial" size="2">
                      <xsl:value-of select="normalize-space(.)"></xsl:value-of>
                    </font>
                  </td>

                  <xsl:if test="following-sibling::FIELD">
                    <xsl:variable name="drilldownName">
                      <xsl:value-of select="following-sibling::FIELD/@NAME"></xsl:value-of>
                    </xsl:variable>
                    <xsl:choose>
                      <xsl:when test="//APPLICATION/SCREEN/VIEW/APPLET/LIST/RS_HEADER/METHOD[@NAME='Drilldown']/@FIELD=$drilldownName">
                        <td align="left">
                          <font face="Arial" size="2">
                            <xsl:element name="A">
                              <xsl:attribute name="HREF">
                                <xsl:value-of select="concat(normalize-space($link-prefix),'R=',$rowid,$link-suffix)"></xsl:value-of>&amp;F=<xsl:value-of select="following-sibling::FIELD/@VARIABLE"></xsl:value-of>
                              </xsl:attribute>
                              <xsl:value-of select="normalize-space(following-sibling::FIELD)"></xsl:value-of>
                            </xsl:element>
                          </font>
                        </td>
                      </xsl:when>
                      <xsl:otherwise>
                        <td align="left">
                          <font face="Arial" size="2">
                            <xsl:value-of select="normalize-space(following-sibling::FIELD)"></xsl:value-of>
                          </font>
                        </td>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:if>
                </tr>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>
        </xsl:when>

        <!-- For 3 Column Field Values -->
        <xsl:when test="$numField =3">
          <xsl:for-each select="FIELD|CONTROL">
            <xsl:choose>
              <!--  if the field is the drilldown field then create a link on the display data -->              
              <xsl:when test="//APPLICATION/SCREEN/VIEW/APPLET/LIST/RS_HEADER/METHOD[@NAME='Drilldown']/@FIELD=@NAME">
                <tr>
                  <td align="left" colspan="2">
                    <font face="Arial" size="2">
                      <xsl:element name="A">
                        <xsl:attribute name="HREF">
                          <xsl:value-of select="concat(normalize-space($link-prefix),'R=',$rowid,$link-suffix)"></xsl:value-of>&amp;F=<xsl:value-of select="@VARIABLE"></xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of select="."></xsl:value-of>
                      </xsl:element>
                    </font>
                  </td>
                </tr>
              </xsl:when>
              <xsl:otherwise>
                <td align="left" colspan="1">
                  <font face="Arial" size="2">
                    <xsl:value-of select="normalize-space(.)"></xsl:value-of>
                  </font>
                </td>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:when>

        <!-- For 2 Column Field Values -->
        <xsl:otherwise>
          <tr>
            <xsl:for-each select="FIELD|CONTROL">
              <xsl:choose>
                <!--  if the field is the drilldown field then create a link on the display data -->
                <xsl:when test="//APPLICATION/SCREEN/VIEW/APPLET/LIST/RS_HEADER/METHOD[@NAME='Drilldown']/@FIELD=@NAME">
                  <td align="left">
                    <font face="Arial" size="2">
                      <xsl:element name="A">
                        <xsl:attribute name="HREF">
                          <xsl:value-of select="concat(normalize-space($link-prefix),'R=',$rowid,$link-suffix)"></xsl:value-of>&amp;F=<xsl:value-of select="@VARIABLE"></xsl:value-of>
                        </xsl:attribute>
                        <xsl:value-of select="normalize-space(.)"></xsl:value-of>
                      </xsl:element>
                    </font>
                  </td>
                </xsl:when>
                <xsl:otherwise>
                  <td align="left">
                    <font face="Arial" size="2">
                      <xsl:value-of select="."></xsl:value-of>
                    </font>
                  </td>
                </xsl:otherwise>
              </xsl:choose>
              <!--
                <xsl:variable name="empty_field">
                <xsl:value-of select="."></xsl:value-of>
                </xsl:variable>
                <xsl:if test="string-length($empty_field)!=0">
                <br></br>
                </xsl:if>
              -->
            </xsl:for-each>
          </tr>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!--  =========================== Anchor URL Processing =============================== -->
  <!--  ANCHOR Template  builds the URL for drilldowns and links  -->
  <xsl:template match="ANCHOR">
    <xsl:text>start.swe?</xsl:text>
    <xsl:apply-templates select="CMD|INFO"></xsl:apply-templates>
  </xsl:template>

  <xsl:template match="CMD">
    <xsl:value-of select="@NAME"></xsl:value-of>=<xsl:value-of select="@VALUE"></xsl:value-of>
    <xsl:apply-templates select="ARG"></xsl:apply-templates>
  </xsl:template>

  <xsl:template match="ARG">
    <xsl:variable name="arg">
      <xsl:if test="string-length(normalize-space(.)) >0">
        <xsl:variable name="argstring">
          <xsl:if test="@NAME='Pu' or @NAME='R' or @NAME='Rs'"><!--  replace + with %2B  -->
            <xsl:call-template name="ENCODE_ARG">
              <xsl:with-param name="encode_string" select="normalize-space(.)"></xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:if test="not (@NAME='Pu' or @NAME='R' or @NAME='Rs')">
            <xsl:value-of select="normalize-space(.)"></xsl:value-of>
          </xsl:if>
        </xsl:variable>
        <xsl:value-of select="$argstring"></xsl:value-of>
      </xsl:if>
    </xsl:variable>
    <xsl:text>&amp;</xsl:text>
    <xsl:value-of select="@NAME"></xsl:value-of>=<xsl:value-of select="$arg"></xsl:value-of>
  </xsl:template>

  <xsl:template name="ENCODE_ARG">
    <xsl:param name="encode_string"></xsl:param>
    <xsl:if test="not (contains($encode_string, '+'))">
      <xsl:value-of select="$encode_string"></xsl:value-of>
    </xsl:if>
    <xsl:if test="contains($encode_string, '+')">
      <xsl:value-of select="substring-before($encode_string, '+')"></xsl:value-of>
      <xsl:text>%2B</xsl:text><!--  replace + with %2B  -->
      <xsl:call-template name="ENCODE_ARG">
        <xsl:with-param name="encode_string" select="substring-after($encode_string, '+')"></xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="INFO">
    <xsl:variable name="info">
      <xsl:if test="string-length(normalize-space(.)) >0"><!-- <xsl:value-of select="."/> -->
        <xsl:value-of select="normalize-space(.)"></xsl:value-of>
      </xsl:if>
    </xsl:variable>
    <xsl:text>&amp;</xsl:text>
    <xsl:value-of select="@NAME"></xsl:value-of>=<xsl:value-of select="$info"></xsl:value-of>
  </xsl:template>
</xsl:stylesheet>