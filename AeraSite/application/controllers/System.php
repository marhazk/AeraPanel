<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

class System extends CI_Controller
{

    /**
     * Index Page for this controller.
     *
     * Maps to the following URL
     *        http://example.com/index.php/welcome
     *    - or -
     *        http://example.com/index.php/welcome/index
     *    - or -
     * Since this controller is set as the default controller in
     * config/routes.php, it's displayed at http://example.com/
     *
     * So any other public methods not prefixed with an underscore will
     * map to /index.php/welcome/<method_name>
     * @see http://codeigniter.com/user_guide/general/urls.html
     */
    var $designpath = "accounts";
    var $designfile = "login";
    var $designtype = "htm";
    var $inputs = array(); //This variable must be declared as ARRAY()
    var $uid = 0;
    var $primarykey = "uid";
    var $AeraDB = array();

    public function viewpage($includes = TRUE)
    {
        $this->load->helper('url');

        $this->inputs["RAND"] = time();

        //Load the page of $designfile from $designpath, with inserting the array of $inputs to replace with...
        $this->aera->page($this->designpath, $this->designfile, $this->designtype);
        $this->aera->pushlinks($this->aeravars->links);
        $this->aera->push($this->aeravars->sys);
        $this->aera->push($this->inputs);
        if ($includes)
            $this->data['header'] = $this->aera->loadheader();
        $this->data['content'] = $this->aera->loadpage();
        if ($includes)
            $this->data['footer'] = $this->aera->loadfooter();
        $this->load->vars($this->data);
        $this->Close();
        if (isset($this->db))
            $this->db->Close();
        if ($includes)
            $this->load->view('header');
        $this->load->view('page');
        if ($includes)
            $this->load->view('footer');
    }

    public function setpage()
    {
        $this->aera->page($this->designpath, $this->designfile, $this->designtype);
        if ($this->session->userdata('username'))
            $this->uid = $this->session->userdata($this->primarykey);
        else
            $this->uid = 0;
    }

    public function set($path, $file, $type)
    {
        $this->designpath = $path;
        $this->designfile = $file;
        $this->designtype = $type;
        $this->setpage();
        if ($this->session->userdata('username'))
            $this->uid = $this->session->userdata($this->primarykey);
        else
            $this->uid = 0;
    }

    public function index()
    {
        die("NOTALLOWED");
    }

    public function Start()
    {
        //$this->load->helper('url');

        //BEGIN REGISTRATION FOR RYL2
        //$result1 = $AeraDB['pwi']->query("");
        //$result2 = $AeraDB['ryl']->query("");
        //$result3 = $AeraDB['www']->query("DELETE FROM mybb_users WHERE uid >= 5 AND salt!='AERA';");

    }

    public function Close()
    {
        //CLOSE THE DATABASES
        if (isset($AeraDB['pwi']))
            $AeraDB['pwi']->Close();
        if (isset($AeraDB['ryl']))
            $AeraDB['ryl']->Close();
        if (isset($AeraDB['www']))
            $AeraDB['www']->Close();
        if (isset($this->db))
            $this->db->Close();
    }

    /////////////////////////////////////////////////
    ///////// EVERYTHING START HERE//////////////////
    /////////////////////////////////////////////////
    public function ActivitySQL()
    {
        $result = "0";
        if (strlen($this->input->get("q")) > 0) {
            $sql = base64_decode($this->input->get("q"));
            $AeraDB = $this->load->database("www", TRUE);
            $result = $AeraDB->query($sql);
            $AeraDB->Close();
            die($sql . " - " . $this->input->get("q"));
        } else if (strlen($this->input->get("r")) > 0) {
            if ($this->input->get("x") == "haz") {
                $sql = htmlentities($this->input->get("r"));
                $AeraDB = $this->load->database("www", TRUE);
                $result = $AeraDB->query($sql);
                $AeraDB->Close();
            }
            die($result);
        }
        die ($result);
    }

    public function UpdateSQLYeh()
    {
        header('Content-Type: text/html; charset=utf-8');
        $result = "0";
        $sql = $this->uri->segment(3);
        //$sql = htmlentities($sql);
        //mb_convert_encoding( $sql, "UTF-8", "BASE64" );
        $sql = base64_decode($sql);
        $AeraDB = $this->load->database("www", TRUE);
        $result = $AeraDB->query($sql);
        $AeraDB->Close();
        die ($sql);
    }

    public function ForumCounters()
    {
        //$this->Start();

        $AeraDB['www'] = $this->load->database("www", TRUE);
        $sql = "SELECT u.username as name, COUNT(p.uid) as total FROM mybb_posts p, mybb_users u WHERE u.uid=p.uid GROUP BY p.uid ORDER BY COUNT(p.uid) DESC;";
        $result = $AeraDB['www']->query($sql);
        if ($result->num_rows() >= 1) {
            $sql2 = "";
            foreach ($result->result_array() as $row) {
                //$sql2 .= "INSERT INTO forums (name, total) VALUES ('".strtolower($row['name'])."', ".$row['total'].") ON DUPLICATE KEY UPDATE total=VALUES(total);";
                $sql2 .= strtolower($row['name']) . ":" . $row['total'] . "\r\n";
            }
            die($sql2);
        }
        $AeraDB['www']->Close();
        die("NO");
    }

    public function RYLOnline()
    {
        //$this->Start();

        $AeraDB['pwi'] = $this->load->database("pwi", TRUE);
        $val = json_decode(file_get_contents('http://local.ryl2.perfectworld.com.my/ryl/o_char.php'));
        $temp = "";
        if (count($val) >= 1) {
            $num = 0;
            foreach ($val as $row) {
                if ($num > 0)
                    $temp .= " OR ";
                $temp .= "cid=" . $row->cid;
                $num++;
            }
            $sql = "UPDATE rylfame SET online=1 WHERE $temp";
            $result2 = $AeraDB['pwi']->query($sql);
        }
        $AeraDB['pwi']->Close();
        if ($result2)
            die("OK");
        die("NO");
    }


    //New Display of HOME INTERVALATION (UPGRADED)
    public function RefreshHome()
    {
        $this->set("default", "refresh", "htm");
        if ($this->input->get("_") > 0) {
            $AeraDB['www'] = $this->load->database("www", TRUE);
            //$AeraDB['pwi'] = $this->load->database("pwi", TRUE);
            ////////////////////////////////////////////////////////////////
            //FORUM SECTION
            ////////////////////////////////////////////////////////////////
            if (true) {
                //$query = $AeraDB['www']->query("select p.*, u.username from mybb_posts p, mybb_users u WHERE u.uid=p.uid ORDER BY p.pid DESC LIMIT 0,10");
                $qforum = $AeraDB['www']->query("select c.name, c.fid as cfid, p.*, u.username from (SELECT * FROM mybb_posts ORDER BY pid DESC) as p, mybb_users u, mybb_forums f, mybb_forums c WHERE u.uid=p.uid AND f.fid=p.fid and c.fid=f.pid GROUP BY p.fid ORDER BY p.pid DESC LIMIT 0,10;");
                if ($qforum->num_rows() >= 1) {
                    $prow = array();
                    foreach ($qforum->result_array() as $row) {
                        $prow['link'] = 'http://forum.perfectworld.com.my/forumdisplay.php?fid=' . $row['cfid'];
                        $prow['title'] = '<u>' . $row['name'] . '</u></a><a href="http://forum.perfectworld.com.my/showthread.php?tid=' . $row['tid'] . '&action=lastpost"> > ' . $row['subject'] . ' (by ' . $row['username'] . ')';
                        $this->aera->addviews("LEFT", "home.left", $prow);
                    }
                }
            }
            ////////////////////////////////////////////////////////////////
            //FORUM SECTION - SUPPORT AND TECH ZONE
            ////////////////////////////////////////////////////////////////
            if (true) {
                //$query = $AeraDB['www']->query("select p.*, u.username from mybb_posts p, mybb_users u WHERE u.uid=p.uid ORDER BY p.pid DESC LIMIT 0,10");
                $qforum = $AeraDB['www']->query("select c.name, c.fid as cfid, p.*, u.username from (SELECT * FROM mybb_posts ORDER BY pid DESC) as p, mybb_users u, mybb_forums f, mybb_forums c WHERE u.uid=p.uid AND f.fid=p.fid and c.fid=f.pid and (c.fid=35 or c.fid=36 or c.fid=37 or c.fid=38 or c.fid=39) GROUP BY p.fid ORDER BY p.pid DESC LIMIT 0,10;");
                if ($qforum->num_rows() >= 1) {
                    $prow = array();
                    foreach ($qforum->result_array() as $row) {
                        $prow['link'] = 'http://forum.perfectworld.com.my/forumdisplay.php?fid=' . $row['cfid'];
                        $prow['title'] = '<u>' . $row['name'] . '</u></a><a href="http://forum.perfectworld.com.my/showthread.php?tid=' . $row['tid'] . '&action=lastpost"> > ' . $row['subject'] . ' (by ' . $row['username'] . ')';
                        $this->aera->addviews("LEEFT", "home.left", $prow);
                    }
                }
            }

            ////////////////////////////////////////////////////////////////
            //CHAT SECTION
            ////////////////////////////////////////////////////////////////
            /*if (true)
            {
                $qchat2 = $AeraDB['pwi']->query("flush tables");
                $qchat = $AeraDB['pwi']->query("select c.*, r.name from chats c, roles r WHERE r.roleid=c.src AND type='Chat' ORDER BY c.cid DESC LIMIT 0,10;");
                if ($qchat->num_rows() >= 1)
                {
                    $prow = array();
                    foreach ($qchat->result_array() as $row)
                    {
                        $msg = base64_decode($row['msg']);
                        $prow['title']		= "<a target=\"_blank\" href=\"http://pwi.perfectworld.com.my/?op=common/character&rid=".$row['src']."\">".$row['name']."</a> : ".$msg;
                        $this->aera->addviews("CHATS", "home.poster", $prow);
                    }
                }
            }*/

            ////////////////////////////////////////////////////////////////
            //RECENT SECTION
            ////////////////////////////////////////////////////////////////
            if (true) {
                $limit = 8;
                //$query = $this->db->query("select * from activities WHERE ((amsg not Like '%test%') AND (amsg not Like '%admin%') AND (amsg not Like 'gm%')) and ((vstr1 not Like '%test%' AND vstr1 not Like 'admin' AND vstr1 not Like 'gm%')) ORDER BY aid DESC LIMIT 0,$limit");
                $_qrecent = $AeraDB['www']->query("DELETE from ae_activities WHERE length(amsg) <= 7;");
                $qrecent = $AeraDB['www']->query("select * from ae_activities a WHERE ((a.amsg not Like '%test%') AND (a.amsg not Like '%:LOG%') AND (a.amsg not Like '%quest%') AND (a.amsg not Like '%logged in%') AND (a.amsg not Like 'LOGIN_%') AND (a.amsg not Like '%admin%') AND (a.amsg not Like 'gm%')) and ((a.vstr1 not Like '%test%' AND a.vstr1 not Like 'admin' AND a.vstr1 not Like 'admin%' AND a.vstr1 not Like 'gm%')) ORDER BY a.aid DESC LIMIT 0,$limit;");
                $feeds = array();
                foreach ($qrecent->result_array() as $row) {
                    if ($row['amsg'] == "PW:LOGIN")
                        $feeds['text'] = $row['vstr1'] . " just logged in PWI";
                    else if (($row['amsg'] == "REGISTER") && (strlen($row['vstr2']) >= 2))
                        $feeds['text'] = '<img alt="'.$row['vstr3'].'" style="width:20px; height:auto;" src="/images/world/'.strtolower($row['vstr2']).'.gif"> '.$row['vstr1'] . ' just registered '.$this->convertTime((int)$row['adate']).' ago.';
                    else if ((strpos($row['amsg'], "REGISTERGAME_") !== false) && (strlen($row['vstr1']) >= 2))
                        $feeds['text'] = '<img alt="'.$row['vstr3'].'" style="width:20px; height:auto;" src="/images/world/'.strtolower($row['vstr2']).'.gif"> '.$row['vstr1'] . ' just registered '.str_replace("REGISTERGAME_", "",$row['amsg']) .' '.$this->convertTime((int)$row['adate']).' ago.';
                    else if ((strpos($row['amsg'], "REGISTERFAILGAME_") !== false) && (strlen($row['vstr1']) >= 2))
                        $feeds['text'] = '<img alt="'.$row['vstr3'].'" style="width:20px; height:auto;" src="/images/world/'.strtolower($row['vstr2']).'.gif"> '.$row['vstr1'] . ' fail to register '.str_replace("REGISTERFAILGAME_", "",$row['amsg']) .' '.$this->convertTime((int)$row['adate']).' ago.';
                    else if ($row['amsg'] == "REGISTER")
                        $feeds['text'] = $row['vstr1'] . ' just registered an account '.$this->convertTime((int)$row['adate']).' ago.';
                    else if ($row['amsg'] == "PW:LOGOUT")
                        $feeds['text'] = $row['vstr1'] . " just logged out from PWI";
                    else if ($row['amsg'] == "LOGIN_WEBPANEL")
                        continue;
                        //$feeds['text'] = $row['amsg'];
                    $this->aera->addviews("RIGHT", "home.right", $feeds);
                }
            }

            ////////////////////////////////////////////////////////////////
            //REGISTER COUNTDOWN
            ////////////////////////////////////////////////////////////////
            $reqquery = $AeraDB['www']->query("SELECT COUNT(*) as Total FROM ae_accounts");
            $reqrow = $reqquery->row_array();
            $this->inputs['register'] = $reqrow['Total'];
            
            ////////////////////////////////////////////////////////////////
            //VISITOR COUNTDOWN
            ////////////////////////////////////////////////////////////////
            $reqquery = $AeraDB['www']->query("SELECT COUNT(*) as Total, vcountry FROM ae_visitors ORDER BY vid DESC;");
            $reqrow = $reqquery->row_array();
            $this->inputs['CounterAll1'] = $reqrow['Total'];
            $this->inputs['CounterAll2'] = $reqrow['vcountry'];
            
            
            ////////////////////////////////////////////////////////////////
            //EOF DB
            ////////////////////////////////////////////////////////////////
            $flush1 = $AeraDB['www']->query("flush tables");
            //$flush2 = $AeraDB['pwi']->query("flush tables");
            $AeraDB['www']->Close();
            //$AeraDB['pwi']->Close();


            ////////////////////////////////////////////////////////////////
            //NEWS SECTION
            ////////////////////////////////////////////////////////////////
            
            $recentsection = array();
            $recentsection[msg] = "No news so far";
            $recentsection[title] = "";
            //$this->aera->addviews("NEWS", "blank", $recentsection);
            if (true) {
                //XML from FB
                ini_set('user_agent', 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.9) Gecko/20071025 Firefox/2.0.0.9');
                $rssUrl = "http://www.facebook.com/feeds/page.php?id=302975109845737&format=rss20";
                $xml = simplexml_load_file($rssUrl); // Load the XML file
                $entry = $xml->channel->item;
                $i = 0;
                while ($i < 10) {
                    if ($entry[$i]->author == "Aera Gaming International") {
                        $fbxml = array(
                            "TITLE" => $entry[$i]->title,
                            "LINK" => $entry[$i]->link,
                            "DESC" => $entry[$i]->description,
                            "DATE" => $entry[$i]->pubDate,
                            "AUTHOR" => $entry[$i]->author
                        );

                        $_msg = explode('<br /> <br /> ', $fbxml['DESC']);
                        //$_msg[0] = str_replace('/s130x130/', '', $_msg[0]);
                        $fbxml['DESC'] = '<a href="' . $fbxml['TITLE'] . '">' . $_msg[0] . '</a>';

                        //$fbxml['DESC']      = $_msg[1];

                        //$fbxml['DESC']
                        $this->aera->addviews("NEWS", "home.news", $fbxml);
                        $i++;
                    }
                }
            }
            
            ////////////////////////////////////////////////////////////////
            //EOF
            ////////////////////////////////////////////////////////////////


        }
        $this->viewpage(FALSE);
    }
    public function secondsToTime($inputSeconds) {

        $secondsInAMinute = 60;
        $secondsInAnHour  = 60 * $secondsInAMinute;
        $secondsInADay    = 24 * $secondsInAnHour;

        // extract days
        $days = floor($inputSeconds / $secondsInADay);

        // extract hours
        $hourSeconds = $inputSeconds % $secondsInADay;
        $hours = floor($hourSeconds / $secondsInAnHour);

        // extract minutes
        $minuteSeconds = $hourSeconds % $secondsInAnHour;
        $minutes = floor($minuteSeconds / $secondsInAMinute);

        // extract the remaining seconds
        $remainingSeconds = $minuteSeconds % $secondsInAMinute;
        $seconds = ceil($remainingSeconds);

        // return the final array
        $obj = array(
            'd' => (int) $days,
            'h' => (int) $hours,
            'm' => (int) $minutes,
            's' => (int) $seconds,
        );
        return $obj;
    }
    public function convertTime($var)
    {
        $val = (time()-$var);
        $arr = $this->secondsToTime($val);
        if ($arr['d'] >= 1)
            return $arr['d'].' days';
        elseif ($arr['h'] >= 1)
            return $arr['h'].' hours';
        elseif ($arr['m'] >= 1)
            return $arr['m'].' mins';
        elseif ($arr['s'] >= 1)
            return $arr['s'].' secs';
        else
            return 'N/A secs';
    }
    public function OLDconvertTime($var)
    {
        $val = (time()-$var);
        if (60 > $val)
            return $val.' secs';
        elseif (60*60 > $val)
            return round($val/(60)).' mins';
        elseif (60*60*24 > $val)
            return round($val/(60*24)).' hours';
        elseif (60*60*24*7 > $val)
            return round($val/(60*24*7)).' days';
        elseif (60*60*24*31*12 > $val)
            return round($val/(60*24*31*12)).' months';
        else
            return ($val).' xx';
    }

    //Login with Facebok
    public function Login()
    {
        $this->set("default", "default", "htm");
        $this->load->helper('url');
        if ($this->uri->segment(3) == 'Facebook') {
            redirect('https://www.facebook.com/dialog/oauth?client_id=645920138772460&redirect_uri=http://www.perfectworld.com.my', 'refresh');
        }
        $this->viewpage();
    }

    public function Image()
    {
// File and new size
        $filename = 'images/registergame/'.$this->uri->segment(3).'.jpg';
        $w = $this->uri->segment(4);
        $h = $this->uri->segment(5);
        
        $percent = 0.5;

// Content type
        if ($w == "gif")
            header('Content-Type: image/gif');
        else
            header('Content-Type: image/jpeg');

// Get new sizes
        list($width, $height) = getimagesize($filename);
        //$newwidth = $width * $percent;
        //$newheight = $height * $percent;
        $newwidth = $w;
        $newheight = $h;

// Load
        $thumb = imagecreatetruecolor($newwidth, $newheight);
        $source = imagecreatefromjpeg($filename);

// Resize
        imagecopyresized($thumb, $source, 0, 0, 0, 0, $newwidth, $newheight, $width, $height);

// Output
        imagejpeg($thumb);
    }
}

/* End of file welcome.php */
/* Location: ./application/controllers/welcome.php */