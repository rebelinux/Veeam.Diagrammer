digraph g {
    charset="UTF-8";
    labelloc="t";
    style="rounded";
    size="16,9!";
    label="Veeam Implementation Diagram \n ";
    fontcolor="#005f4b";
    compound="true";
    imagepath="C:\Users\jocolon\Documents\WindowsPowerShell\Modules\Veeam.Diagrammer\icons";
    splines="ortho";
    ratio="fill";
    rankdir="TB";
    fontsize="32";
    node [fontname="Courier New";fillcolor="transparent";labelloc="t";shape="none";penwidth="1";label="";margin="0";style="filled";fontsize="12";]
    edge [color="#71797E";style="dashed";dir="both";arrowtail="dot";]
    subgraph clusterBackupServer {
        label="Backup Server";
        bgcolor="#ceedc4";
        fontsize="18";
        "BackupServer" [label="";style="invis";shape="point";]
        "VEEAM-VBR-01V" [label=<<TABLE border='0' cellborder='0' cellspacing='5' cellpadding='0'><TR><TD ALIGN='center' colspan='1'><img src='VBR_server.png'/></TD></TR><TR><TD align='center' VALIGN='Bottom'><B>VEEAM-VBR-01V</B></TD></TR><TR><TD align='center' VALIGN='Bottom'>Role:Backup Server</TD></TR><TR><TD align='center' VALIGN='Bottom'>IP:10.0.0.1</TD></TR></TABLE>>;]
        "VEEAM-SQL-01V" [label=<<TABLE border='0' cellborder='0' cellspacing='5' cellpadding='0'><TR><TD ALIGN='center' colspan='1'><img src='Microsoft_SQL_DB.png'/></TD></TR><TR><TD align='center' VALIGN='Bottom'><B>VEEAM-SQL-01V</B></TD></TR><TR><TD align='center' VALIGN='Bottom'>Role:Database</TD></TR><TR><TD align='center' VALIGN='Bottom'>IP:10.0.0.2</TD></TR></TABLE>>;]
        "VEEAM-VBR-01V"->"VEEAM-SQL-01V" [arrowtail="normal";arrowhead="normal";]
        { rank=same;  "VEEAM-VBR-01V"; "VEEAM-SQL-01V"; }
    }

    subgraph clusterProxies {
        label="Backup Proxies";
        style="dashed";
        fontsize="18";
        "Proxies" [label="";style="invis";shape="point";]
        "VEEAM-PRX-01V" [label=<<TABLE border='0' cellborder='0' cellspacing='5' cellpadding='0'><TR><TD ALIGN='center' colspan='1'><img src='Proxy_Server.png'/></TD></TR><TR><TD align='center' VALIGN='Bottom'><B>VEEAM-PRX-01V</B></TD></TR><TR><TD align='center' VALIGN='Bottom'>Role:Proxy Server</TD></TR><TR><TD align='center' VALIGN='Bottom'>IP:10.0.0.14</TD></TR></TABLE>>;]
        "VEEAM-PRX-02V" [label=<<TABLE border='0' cellborder='0' cellspacing='5' cellpadding='0'><TR><TD ALIGN='center' colspan='1'><img src='Proxy_Server.png'/></TD></TR><TR><TD align='center' VALIGN='Bottom'><B>VEEAM-PRX-02V</B></TD></TR><TR><TD align='center' VALIGN='Bottom'>Role:Proxy Server</TD></TR><TR><TD align='center' VALIGN='Bottom'>IP:10.0.0.12</TD></TR></TABLE>>;]
        "VEEAM-VBR-01V"->"VEEAM-PRX-01V" 
        "VEEAM-VBR-01V"->"VEEAM-PRX-02V" 
        { rank=same;  "VEEAM-PRX-01V"; "VEEAM-PRX-02V"; "VEEAM-VBR-01V"; }
    }

    subgraph clusterRepos {
        label="Backup Repository";
        style="dashed";
        fontsize="18";
        "Repos" [label="";style="invis";shape="point";]
        "VEEAM-REPO-01V" [label=<<TABLE border='0' cellborder='0' cellspacing='5' cellpadding='0'><TR><TD ALIGN='center' colspan='1'><img src='VBR_Repository.png'/></TD></TR><TR><TD align='center' VALIGN='Bottom'><B>VEEAM-REPO-01V</B></TD></TR><TR><TD align='center' VALIGN='Bottom'>Role:Repository</TD></TR><TR><TD align='center' VALIGN='Bottom'>IP:10.0.0.23</TD></TR></TABLE>>;]
        "VEEAM-REPO-02V" [label=<<TABLE border='0' cellborder='0' cellspacing='5' cellpadding='0'><TR><TD ALIGN='center' colspan='1'><img src='VBR_Repository.png'/></TD></TR><TR><TD align='center' VALIGN='Bottom'><B>VEEAM-REPO-02V</B></TD></TR><TR><TD align='center' VALIGN='Bottom'>Role:Repository</TD></TR><TR><TD align='center' VALIGN='Bottom'>IP:10.0.0.30</TD></TR></TABLE>>;]
        "VEEAM-REPO-02V"->"VEEAM-VBR-01V" 
        "VEEAM-REPO-01V"->"VEEAM-VBR-01V" 
        subgraph clusterSOBR {
            label="SOBR Repository";
            style="dashed";
            fontsize="18";
            "SOBR" [label="";style="invis";shape="point";]
            "VEEAM-REPO-03V" [label=<<TABLE border='0' cellborder='0' cellspacing='5' cellpadding='0'><TR><TD ALIGN='center' colspan='1'><img src='Scale-out_Backup_Repository.png'/></TD></TR><TR><TD align='center' VALIGN='Bottom'><B>VEEAM-REPO-03V</B></TD></TR><TR><TD align='center' VALIGN='Bottom'>Role:SOBR</TD></TR><TR><TD align='center' VALIGN='Bottom'>IP:10.0.0.24</TD></TR></TABLE>>;]
            "VEEAM-MINIO-01V" [label=<<TABLE border='0' cellborder='0' cellspacing='5' cellpadding='0'><TR><TD ALIGN='center' colspan='1'><img src='Scale-out_Backup_Repository.png'/></TD></TR><TR><TD align='center' VALIGN='Bottom'><B>VEEAM-MINIO-01V</B></TD></TR><TR><TD align='center' VALIGN='Bottom'>Role:SOBR</TD></TR><TR><TD align='center' VALIGN='Bottom'>IP:10.0.0.25</TD></TR></TABLE>>;]
            "VEEAM-MINIO-01V"->"VEEAM-VBR-01V" 
            "VEEAM-REPO-03V"->"VEEAM-VBR-01V" 
        }

    }

    subgraph clusterWANACCEL {
        label="Wan Accelerators";
        style="dashed";
        fontsize="18";
        "WANACCEL" [label="";style="invis";shape="point";]
        "VEEAM-WAN-01V" [label=<<TABLE border='0' cellborder='0' cellspacing='5' cellpadding='0'><TR><TD ALIGN='center' colspan='1'><img src='WAN_accelerator.png'/></TD></TR><TR><TD align='center' VALIGN='Bottom'><B>VEEAM-WAN-01V</B></TD></TR><TR><TD align='center' VALIGN='Bottom'>Role:WAN Accelerator</TD></TR><TR><TD align='center' VALIGN='Bottom'>IP:10.0.0.9</TD></TR></TABLE>>;]
        "VEEAM-WAN-02V" [label=<<TABLE border='0' cellborder='0' cellspacing='5' cellpadding='0'><TR><TD ALIGN='center' colspan='1'><img src='WAN_accelerator.png'/></TD></TR><TR><TD align='center' VALIGN='Bottom'><B>VEEAM-WAN-02V</B></TD></TR><TR><TD align='center' VALIGN='Bottom'>Role:WAN Accelerator</TD></TR><TR><TD align='center' VALIGN='Bottom'>IP:10.0.0.10</TD></TR></TABLE>>;]
        "VEEAM-VBR-01V"->"VEEAM-WAN-01V" 
        "VEEAM-VBR-01V"->"VEEAM-WAN-02V" 
        "VEEAM-WAN-01V"->"VEEAM-WAN-02V" [arrowtail="normal";arrowhead="normal";]
        { rank=same;  "VEEAM-WAN-01V"; "VEEAM-WAN-02V"; }
    }

}

