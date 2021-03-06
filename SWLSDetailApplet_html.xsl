<?xml version="1.0" encoding="utf-16"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html" media-type="text/html"></xsl:output>

  <xsl:template match="/">
    <xsl:apply-templates select="APPLICATION/SCREEN/VIEW/APPLET"></xsl:apply-templates>
  </xsl:template>

  <xsl:template match="APPLET">
    <HTML>
      <HEADER>
        <META http-equiv="cache-control" content="no-cache"></META>
      </HEADER>
      <BODY>
        <!--  Error message  -->
        <xsl:if test="string-length(ERROR)>0">
          <xsl:value-of select="ERROR"></xsl:value-of>
          <br></br>
        </xsl:if>
        <!--  APPLET TITLE show in bold  -->
        <b>
          <xsl:apply-templates select="CONTROL[@ID=1 or @ID=100]"></xsl:apply-templates>
        </b>
        <!--  All other controls  -->
        <xsl:apply-templates select="CONTROL[@ID!=1 and @ID!=100]"></xsl:apply-templates>
      </BODY>
    </HTML>
  </xsl:template>

  <!--  create a Pick List for input  -->
  <xsl:template name="build_picklist">
    <xsl:element name="Select">
      <xsl:attribute name="Name">
        <xsl:value-of select="@VARIABLE"></xsl:value-of>
      </xsl:attribute>
      <xsl:for-each select="PICK_LIST/OPTION">
        <xsl:element name="Option">
          <xsl:value-of select="normalize-space()"></xsl:value-of>
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <!--  Create an input text box -->
  <xsl:template name="build_textbox">
    <xsl:element name="Input">
      <xsl:attribute name="type">
        <xsl:text>text</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="Name">
        <xsl:value-of select="@VARIABLE"></xsl:value-of>
      </xsl:attribute>
      <xsl:attribute name="Value">
        <xsl:value-of select="normalize-space()"></xsl:value-of>
      </xsl:attribute>
    </xsl:element>
    <br></br>
  </xsl:template>

  <xsl:template match="CONTROL">
    <xsl:for-each select=".">
      <xsl:variable name="appletclass">
        <xsl:value-of select="../@CLASS"></xsl:value-of>
      </xsl:variable>
      <xsl:choose>
        <!--  here you choose all Controls with a HTML_TYPE of Link -->
        <!--  Parse the Next records link -->
        <xsl:when test="@HTML_TYPE='RecNavNxt'">
          <xsl:call-template name="build_simple_link"></xsl:call-template>
        </xsl:when><!--  Parse the Previous Records link -->
        <xsl:when test="@HTML_TYPE='RecNavPrv'">
          <xsl:call-template name="build_simple_link"></xsl:call-template>
        </xsl:when><!--  Parse any links -->
        <xsl:when test="@HTML_TYPE = 'Link'">
          <xsl:choose>
            <!--  Parse links with PushButtons These Cancel links in Edit  views -->
            <xsl:when test="@TYPE='PushButton'">
              <xsl:call-template name="build_simple_link"></xsl:call-template>
            </xsl:when>

            <!--  Parse links with Text boxes These are Field edit links in Detail views -->
            <xsl:when test="@TYPE='TextBox'">
              <xsl:call-template name="build_simple_link"></xsl:call-template>
            </xsl:when>

            <!--  Process all the links with type of lable  -->
            <xsl:when test="@TYPE = 'Label'">
              <!-- check the method type need to distinguish Pick Record links from GotoView links -->
              <xsl:variable name="methodtype">
                <xsl:for-each select="ANCHOR/CMD/ARG">
                  <xsl:if test="@NAME='SWEMethod'">
                    <xsl:value-of select="normalize-space()"></xsl:value-of>
                  </xsl:if>
                </xsl:for-each>
              </xsl:variable>
              <xsl:choose>
                <!--  Process the Pick Record or edit links  -->
                <xsl:when test="$methodtype='EditRecord' or $methodtype='EditField'">
                  <xsl:call-template name="build_simple_link"></xsl:call-template>
                  <br></br>
                </xsl:when>

                <!--  Process the GotoView links - this includes a workaround to enable the link -->
                <xsl:when test="$methodtype='GotoView'">
                  <xsl:variable name="link">
                    <xsl:call-template name="detailmenu_links"></xsl:call-template>
                  </xsl:variable>
                  <xsl:element name="A">
                    <xsl:attribute name="HREF">
                      <xsl:value-of select="$link"></xsl:value-of>
                    </xsl:attribute>
                    <xsl:value-of select="@CAPTION"></xsl:value-of>
                  </xsl:element>
                  <br></br>
                </xsl:when>

                <!-- - Generate all other types of links -->
                <!--  This includes the Search, and New record links -->
                <xsl:otherwise>
                  <xsl:call-template name="build_simple_link"></xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
          </xsl:choose>
        </xsl:when>

        <!--  Parse Controls with HTML_TYPE of Text, MakeCall is shown as text  -->
        <xsl:when test="@HTML_TYPE='Text' or @HTML_TYPE='MakeCall'">
          <xsl:choose>
            <!--  check if control has link -->
            <xsl:when test="ANCHOR">
              <xsl:if test="not(contains(preceding-sibling::CONTROL[1]/@NAME, 'Pick')) and preceding-sibling::CONTROL[1]/@ID!=@ID+100">
                <xsl:value-of select="@CAPTION"></xsl:value-of>
                <br></br>
              </xsl:if>
              <xsl:call-template name="build_field_drilldown_link"></xsl:call-template>
            </xsl:when>

            <xsl:when test="@TYPE='TextBox'">
              <xsl:value-of select="."></xsl:value-of>
              <br></br>
            </xsl:when>

            <!--  otherwise just display the value -->
            <xsl:otherwise>
              <xsl:value-of select="text()"></xsl:value-of>
              <br></br>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when><!--  otherwise just display the value -->
        <xsl:otherwise>
          <xsl:value-of select="."></xsl:value-of>
          <br></br>
        </xsl:otherwise><!--  Do we need code for Field and FieldLabel HTML TYPES  -->
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="build_field_drilldown_link">
    <xsl:variable name="link">
      <xsl:apply-templates select="ANCHOR"></xsl:apply-templates>
    </xsl:variable>
    <xsl:element name="A">
      <xsl:attribute name="HREF">
        <xsl:value-of select="$link"></xsl:value-of>
      </xsl:attribute>
      <xsl:value-of select="text()"></xsl:value-of>
    </xsl:element>
    <br></br>
  </xsl:template>

  <xsl:template name="build_simple_link">
    <xsl:variable name="link">
      <xsl:apply-templates select="ANCHOR"></xsl:apply-templates>
    </xsl:variable>
    <xsl:element name="A">
      <xsl:attribute name="HREF">
        <xsl:value-of select="$link"></xsl:value-of>
      </xsl:attribute>
      <xsl:value-of select="@CAPTION"></xsl:value-of>
    </xsl:element>
    <br></br>
  </xsl:template><!--  Detail View Menu Link Template -->

  <xsl:template name="detailmenu_links">
    <xsl:variable name="targetview">
      <xsl:for-each select="ANCHOR/CMD/ARG">
        <xsl:if test="@NAME='SWETargetView'">
          <xsl:value-of select="normalize-space()"></xsl:value-of>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:for-each select="ANCHOR"><!-- <xsl:value-of select="@PATH"/> -->
      <xsl:text>start.swe?</xsl:text>
      <xsl:for-each select="CMD">
        <xsl:value-of select="@NAME"></xsl:value-of>=<xsl:text>GotoView</xsl:text>
        <xsl:for-each select="ARG">
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
          <xsl:choose>
            <xsl:when test="@NAME='SWEView'">
              <xsl:value-of select="@NAME"></xsl:value-of>=<xsl:value-of select="$targetview"></xsl:value-of>
            </xsl:when>
            <xsl:when test="@NAME='SWEMethod'"></xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@NAME"></xsl:value-of>=<xsl:value-of select="$arg"></xsl:value-of>
            </xsl:otherwise>
          </xsl:choose>

          <!-- <xsl:text>&#38;</xsl:text><xsl:text>&amp;</xsl:text> -->
          <!-- <xsl:value-of select="@NAME"/>=<xsl:value-of select="translate($arg,'&#x20;','+')'"/> -->
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="INFO">
        <xsl:variable name="info">
          <xsl:if test="string-length(normalize-space(.)) >0">
            <xsl:value-of select="."></xsl:value-of>
          </xsl:if>
        </xsl:variable>
        <xsl:text>&amp;</xsl:text>
        <xsl:value-of select="@NAME"></xsl:value-of>=<xsl:value-of select="$info"></xsl:value-of>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <!--  Field content Template  -->
  <xsl:template name="field_content">
    <xsl:value-of select="."></xsl:value-of>
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
    <!--  just return the value and stop  -->
    <xsl:if test="not (contains($encode_string, '+'))">
      <xsl:value-of select="$encode_string"></xsl:value-of>
    </xsl:if>
    <!--  recursive processing  -->
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
      <xsl:if test="string-length(normalize-space(.)) >0">
        <!-- <xsl:value-of select="."/> -->
        <xsl:value-of select="normalize-space(.)"></xsl:value-of>
      </xsl:if>
    </xsl:variable>
    <xsl:text>&amp;</xsl:text>
    <xsl:value-of select="@NAME"></xsl:value-of>=<xsl:value-of select="$info"></xsl:value-of>
  </xsl:template>
</xsl:stylesheet>
