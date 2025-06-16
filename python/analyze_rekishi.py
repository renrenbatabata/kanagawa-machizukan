from dotenv import load_dotenv
import os # load_dotenvを使用するために必要
from math import radians, cos, sin, sqrt, atan2

# 環境変数からAPIキーを読み込む (現在使用しないが、dotenvのロードは残す)
load_dotenv()
# API_KEYは使用しないため削除します
# API_KEY = os.getenv("Maps_API_KEY", "Your_API_Key_Here")

def calculate_distance(lat1, lon1, lat2, lon2):
    """2点間の距離をキロメートルで返す"""
    R = 6371  # 地球の半径（km）
    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)
    a = sin(dlat / 2)**2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon / 2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return R * c

# --- ★★★ ここからがデータベースで管理する歴史的建造物のデータ（例） ★★★ ---
# 実際には、MySQLなどのデータベースから取得するロジックをここに実装します。
# 各辞書は、データベースの1レコードに対応します。
# PDFに記載されている神奈川区の歴史的建造物の情報
HISTORICAL_BUILDINGS_DB = [
    {
        'id': 'shrine_oogane',
        'name': '大綱金刀比羅神社',
        'latitude': 35.4729,  # 例: 正確な緯度経度を設定
        'longitude': 139.6380, # 例: 正確な緯度経度を設定
        'address': '横浜市神奈川区大口通', # 例: より正確な住所を設定
        'type': 'shrine',
        'description': '平安時代の終わりにできたと伝えられる神社です。かつてこのあたりに広がっていた神奈川湊に出入りする船乗りたちから信仰されていました。天狗の伝説でも知られています。' #
    },
    {
        'id': 'temple_henjoin',
        'name': '遍照院',
        'latitude': 35.4750,  # 例: 正確な緯度経度を設定
        'longitude': 139.6390, # 例: 正確な緯度経度を設定
        'address': '横浜市神奈川区栗田谷', # 例: より正確な住所を設定
        'type': 'temple',
        'description': 'お寺までの石段の途中に、竹林が通る珍しい景色が見られるスポットです。度も火をくぐり抜けて残った山門があります。' #
    },
    {
        'id': 'shrine_suzakioogami',
        'name': '洲崎大神',
        'latitude': 35.4700, # 例: 正確な緯度経度を設定
        'longitude': 139.6350, # 例: 正確な緯度経度を設定
        'address': '横浜市神奈川区青木町', # 例: より正確な住所を設定
        'type': 'shrine',
        'description': '神功皇后がつくったとも伝わる神社です。かつて、この神社にあったご神木のアハキがなまり、青木町の町名になったといわれています。' #
    },
    {
        'id': 'temple_sanpouji',
        'name': '三宝寺',
        'latitude': 35.4710, # 例: 正確な緯度経度を設定
        'longitude': 139.6360, # 例: 正確な緯度経度を設定
        'address': '横浜市神奈川区泉町', # 例: より正確な住所を設定
        'type': 'temple',
        'description': 'まるで空中に浮かんでいるようにみえる、ぼしいお寺の寺院です。21の位牌は、麻がらと筆に居した入道として知られています。' #
    },
    {
        'id': 'temple_honkakuuji',
        'name': '本覺寺',
        'latitude': 35.4670, # 例: 正確な緯度経度を設定
        'longitude': 139.6340, # 例: 正確な緯度経度を設定
        'address': '横浜市神奈川区本覚寺', # 例: より正確な住所を設定
        'type': 'temple',
        'description': '当時は、アメリカ領事館でした。当時のアメリカ領事は、人の殺生を払いとし、屋根を上げ、寺の正門を白いペンキで塗り、さらに本堂の中を板で囲い、一般人の立ち入りを禁止していたと伝わっています。' #
    },
    {
        'id': 'temple_jinkoji',
        'name': '甚行寺',
        'latitude': 35.4690, # 例: 正確な緯度経度を設定
        'longitude': 139.6370, # 例: より正確な住所を設定
        'address': '横浜市神奈川区七島町',
        'type': 'temple',
        'description': '当時は、フランス公使館でした。土蔵造りの本堂を改め、公使館にあてたといわれています。' #
    },
    {
        'id': 'temple_fumonji',
        'name': '普門寺',
        'latitude': 35.4705, # 例: 正確な緯度経度を設定
        'longitude': 139.6355, # 例: より正確な住所を設定
        'address': '横浜市神奈川区七島町',
        'type': 'temple',
        'description': '観音の菩薩を祀ったことにより、多くの人々に救いの門を開いている、という意味からと名付けられたそうです。' #
    },
    {
        'id': 'temple_joryuji',
        'name': '浄瀧寺',
        'latitude': 35.4660, # 例: 正確な緯度経度を設定
        'longitude': 139.6330, # 例: より正確な住所を設定
        'address': '横浜市神奈川区台町',
        'type': 'temple',
        'description': '横浜開港当時は、イギリス領事館でした。大空襲で焼けてしまいましたが、当時、イギリス領事が植えた「十月桜」と呼ばれる桜があり、横浜十名木とされました。' #
    },
    {
        'id': 'temple_keiunji',
        'name': '慶運寺',
        'latitude': 35.4650, # 例: 正確な緯度経度を設定
        'longitude': 139.6320, # 例: より正確な住所を設定
        'address': '横浜市神奈川区台町',
        'type': 'temple',
        'description': '横浜開港当時は、フランスの領事館でした。現在では、七福神をまつる寺としても親しまれています。' #
    },
    {
        'id': 'temple_sokoji',
        'name': '宗興寺',
        'latitude': 35.4640, # 例: 正確な緯度経度を設定
        'longitude': 139.6310, # 例: より正確な住所を設定
        'address': '横浜市神奈川区台町',
        'type': 'temple',
        'description': 'アメリカ人宣教師で医者であったヘボンは、この寺で診療を行っていました。たくさんの人がヘボンによって助けられたので、寺にはヘボンの碑が建てられています。ヘボンはまた、ヘボン式ローマ字でも知られています。' #
    },
    {
        'id': 'temple_jobutsuji',
        'name': '成仏寺',
        'latitude': 35.4630, # 例: 正確な緯度経度を設定
        'longitude': 139.6300, # 例: より正確な住所を設定
        'address': '横浜市神奈川区台町',
        'type': 'temple',
        'description': 'ヘボン博士の診療所がありました。アメリカスワルドン領事として滞在していました。ヘボンは本堂に、ブラウンは裏に住んだといわれています。' #
    },
    {
        'id': 'shrine_kumano_konzoin',
        'name': '熊野神社・金蔵院',
        'latitude': 35.4620, # 例: 正確な緯度経度を設定
        'longitude': 139.6290, # 例: より正確な住所を設定
        'address': '横浜市神奈川区台町',
        'type': 'shrine',
        'description': '神社は、もと鳥山にあり、江戸時代の中ごろに滝ノ川町に移され、明治時代のはじめに今の場所になりました。江戸時代の神奈川宿の様子を描いた「金川一覧図」には、西野神社と金蔵院が東西に並んでいる様子や、江戸時代後期の熊野神社の賑わいが描かれています。' #
    },
    {
        'id': 'temple_tokoji',
        'name': '東光寺',
        'latitude': 35.4610, # 例: 正確な緯度経度を設定
        'longitude': 139.6280, # 例: より正確な住所を設定
        'address': '横浜市神奈川区六角橋',
        'type': 'temple',
        'description': '小田原氏の家臣、平子義がつくったといわれる寺です。不動明王は、の守護仏で、江戸城を築いたことで知られる太田道灌が深く信仰していたという説もあります。' #
    },
    {
        'id': 'shrine_shinmeigu',
        'name': '神明宮',
        'latitude': 35.4600, # 例: 正確な緯度経度を設定
        'longitude': 139.6270, # 例: より正確な住所を設定
        'address': '横浜市神奈川区六角橋',
        'type': 'shrine',
        'description': 'かつて境内を流れていた川に、牛王の面をつけた大蛇が現れ、大物主大神およびこの神社に祀ったとの言い伝えもあります。' #
    },
    {
        'id': 'temple_nomannji',
        'name': '能満寺',
        'latitude': 35.4590, # 例: 正確な緯度経度を設定
        'longitude': 139.6260, # 例: より正確な住所を設定
        'address': '横浜市神奈川区六角橋',
        'type': 'temple',
        'description': '鎌倉時代、この地に住む内藤信死という人が、海の中から現れた不動明王像を祀り、お寺を建ててまつったのがはじまりだといわれています。' #
    },
    {
        'id': 'temple_ryosenji',
        'name': '良泉寺',
        'latitude': 35.4580, # 例: 正確な緯度経度を設定
        'longitude': 139.6250, # 例: より正確な住所を設定
        'address': '横浜市神奈川区六角橋',
        'type': 'temple',
        'description': '担当の役人からこの寺を個人の宿にするように命令されましたが、お坊さんは瓦をわざとはがし、修理中だといって断ったといわれています。' #
    },
    {
        'id': 'shrine_kasamotouinari',
        'name': '笠䈢稲荷神社',
        'latitude': 35.4570, # 例: 正確な緯度経度を設定
        'longitude': 139.6240, # 例: より正確な住所を設定
        'address': '横浜市神奈川区六角橋',
        'type': 'shrine',
        'description': '笠をかぶった人がこの神社の鳥居を通ると、笠に蜂がげ落ちたそうです。そのため笠落し稲荷と呼ばれるようになり、その後、笠落を笠䈢に言いかえたといわれています。' #
    },
    # 神奈川宿に関する史跡・名所 (神社仏閣ではないが、重要文化財などとして含める場合)
    {
        'id': 'hist_kamiidaibashi',
        'name': '上台橋',
        'latitude': 35.4665, # 例: 正確な緯度経度を設定
        'longitude': 139.6345, # 例: より正確な住所を設定
        'address': '横浜市神奈川区台町',
        'type': 'historical_site',
        'description': 'かつて、あたりは、磯の音が聞こえる海辺の雨でした。この場所から見えた月は、ひときわ美しかったのでしょう。「神奈川駅中会」にも、その種子が痛かれていました。昭和5年(1930)切り通しができ、その上に橋がかけられました。' #
    },
    {
        'id': 'hist_kanagawadaisekimon',
        'name': '神奈川台の関門跡',
        'latitude': 35.4675, # 例: 正確な緯度経度を設定
        'longitude': 139.6350, # 例: より正確な住所を設定
        'address': '横浜市神奈川区台町',
        'type': 'historical_site',
        'description': '当時、外国人がおそわれる事件がたくさん起こりましたが、犯人はなかなかつかまりませんでした。幕府は、神奈川辺にいくつかの門や番所をつくり、警戒に力を入れました。この時、神奈川店の東西にも関門がつくられ、今は神奈川区役所の石の門に碑が建っています。' #
    },
    {
        'id': 'hist_daimachi_chaya',
        'name': '台町の茶屋',
        'latitude': 35.4685, # 例: 正確な緯度経度を設定
        'longitude': 139.6360, # 例: より正確な住所を設定
        'address': '横浜市神奈川区台町',
        'type': 'historical_site',
        'description': '現在の台町あたりはかつて、江戸を見おろすことのできる景勝地でも有名な景色のよい場所で、多くの茶屋がちならんでいました。この付近の地形は、今でも旧東海道の面影を残しています。' #
    },
    {
        'id': 'hist_ichirizuka',
        'name': '一里塚跡',
        'latitude': 35.4670, # 例: 正確な緯度経度を設定
        'longitude': 139.6340, # 例: より正確な住所を設定
        'address': '横浜市神奈川区台町',
        'type': 'historical_site',
        'description': '江戸時代には、天金刀比羅神社のすぐわきに、日本橋からモつ自の一里塚が置かれていました。一里塚とは江戸の日本橋を起点として一里(約4キロ)ごとにおかれた道しるべのことです。' #
    },
    {
        'id': 'hist_miyamae_shotengai',
        'name': '宮前商店街と旧街道',
        'latitude': 35.4695, # 例: 正確な緯度経度を設定
        'longitude': 139.6375, # 例: より正確な住所を設定
        'address': '横浜市神奈川区宮前町',
        'type': 'historical_site',
        'description': '商店街は、あたりとともに、「神奈川名物」の看板を掲げるところです。かつて、神川の「生せんべい」は有名でした。当時は珍しかったバターをたっぷりと使っていたともいわれ、旅人や地元の人々まで、大変人気がありました。' #
    },
    {
        'id': 'hist_gongen_yama',
        'name': '権現山(車ヶ谷公園)',
        'latitude': 35.4635, # 例: 正確な緯度経度を設定
        'longitude': 139.6315, # 例: より正確な住所を設定
        'address': '横浜市神奈川区台町',
        'type': 'park', # 公園カテゴリ
        'description': '若由屋手には、江戸時代後期の景勝地の絵が描かれています。この絵にあるように現山は、本陣手のある山と車ヶ谷公園のあるところがひと続きになった、ひときわ高い山でしたが、開港から明治時代にかけて神奈川鉄道や港湾用地の埋め立てに大量の土が必要になったため、切りくずされてしまいました。' #
    },
    {
        'id': 'hist_kosatsuba',
        'name': '高札場(神奈川地区センター)',
        'latitude': 35.4655, # 例: 正確な緯度経度を設定
        'longitude': 139.6335, # 例: より正確な住所を設定
        'address': '横浜市神奈川区広台太田町',
        'type': 'historical_site',
        'description': '橋のたもとには高札場が見えます。高札場は幕府のおきてや決まり、承諾などを人々に伝えるための重要な場所でした。高札は、神奈川地区センターに保存されています。' #
    },
    {
        'id': 'hist_kanagawa_o_ido',
        'name': '神奈川の大井戸',
        'latitude': 35.4645, # 例: 正確な緯度経度を設定
        'longitude': 139.6325, # 例: より正確な住所を設定
        'address': '横浜市神奈川区台町',
        'type': 'historical_site',
        'description': '宗興寺の境内のすぐそばには、「神奈川の大井戸」と呼ばれる井戸があります。徳川家康や明治天皇が通る時には、その水が汲まれたといわれています。この井戸は、潮の満ち引きが増えると次の日はお天気がよくなるといわれ、お天気井戸とも呼ばれていました。' #
    },
    {
        'id': 'hist_honjin',
        'name': '本陣跡',
        'latitude': 35.4635, # 例: 正確な緯度経度を設定
        'longitude': 139.6310, # 例: より正確な住所を設定
        'address': '横浜市神奈川区台町',
        'type': 'historical_site',
        'description': '本陣とは、大名や公庫などが泊まるための、幕府に認められている宿のことです。滝の川をはさんで東に神奈川、西に本陣が置かれていました。' #
    },
    {
        'id': 'hist_daiba_ato',
        'name': '神奈川台場跡(神奈川台公園・仲町公園)',
        'latitude': 35.4625, # 例: 正確な緯度経度を設定
        'longitude': 139.6300, # 例: より正確な住所を設定
        'address': '横浜市神奈川区神奈川本町',
        'type': 'historical_site',
        'description': '当時、外国の脅威のため、埋め立てた土を使った「台場」がつくられました。用が設計に関わったといわれ、8,000坪(約26,000㎡)もの広さがありました。現在では宅地化が進みましたが、神奈川台公園では台場の歴史を、仲町公園では、石垣の一部を見ることができます。' #
    },
    {
        'id': 'hist_choenji_doi',
        'name': '長延寺跡・土居跡',
        'latitude': 35.4615, # 例: 正確な緯度経度を設定
        'longitude': 139.6290, # 例: より正確な住所を設定
        'address': '横浜市神奈川区神奈川',
        'type': 'historical_site',
        'description': 'かつては、ここに寺が建っており、開港後はオランダ領事館でした。また、このあたりは、江戸からの入口にあたり、高さ約25メートルの土居といわれる土盛りがありました。右図の「金川」では、一生保のように土塁の図として描かれています。一般的には一の橋と呼ばれ、曲な施設であり、宿場の範囲を示す役割を持っていました。' #
    },
    {
        'id': 'hist_takinokawa_kappa',
        'name': '滝の川と河童の伝説',
        'latitude': 35.4605, # 例: 正確な緯度経度を設定
        'longitude': 139.6280, # 例: より正確な住所を設定
        'address': '横浜市神奈川区',
        'type': 'legend', # 伝説カテゴリ
        'description': 'かつて種々山からひとすじの滝が流れ落ち、滝川となってこの川に届いていたことから、この川を「滝の川」というようになったという説があります。その滝つぼの主であった河童は、神奈川宿に出かけては人々を困らせていました。それを聞いた一人の人が、食事に河童を捕まえると、河童は涙を流しながら「私は大蛇に襲われてしまい、二人の子を養うために、悪いこととは知りながら人々に迷惑をかけていました。二度と悪いことはしないので許してください。お詫びのしるしに、毎晩の食卓に大切なものを差し上げます」と話すので、人も同情して許すことにしました。そしてその後、宿の家に河童の皿が投げ込まれ、それから宿場は静かになったそうです。' #
    },
    {
        'id': 'hist_umitate_takashima',
        'name': '埋立てと高島嘉右衛門',
        'latitude': 35.4595, # 例: 正確な緯度経度を設定
        'longitude': 139.6270, # 例: より正確な住所を設定
        'address': '横浜市神奈川区',
        'type': 'historical_figure', # 歴史的人物関連
        'description': '高島嘉右衛門は、明治時代の初めに横浜を埋め立てるための事業に尽力を尽くしました。野毛山公園の区画から(現在の木場付近)まで、長さ約1.4キロメートル、幅65メートルにわたって海を埋め立て、鉄道用の土手をつくり、高島町と呼ばれるようになりました。' #
    },
    {
        'id': 'hist_tetsudo_aokibashi',
        'name': '鉄道の開通と青木橋',
        'latitude': 35.4585, # 例: 正確な緯度経度を設定
        'longitude': 139.6260, # 例: より正確な住所を設定
        'address': '横浜市神奈川区青木町',
        'type': 'historical_event', # 歴史的出来事関連
        'description': '慶運寺のある高台と幸ヶ谷公園のある丘とは元はひと続きでした。この山を切り崩し、明治5年(1872年、新橋と横浜の間に鉄道が通されました。この工事の時、鉄道をまたいで旧街道を結んで架けられた橋が青木橋です。' #
    },
    {
        'id': 'landmark_miyakawa_kozanyama',
        'name': '宮川香山眞葛ミュージアム',
        'latitude': 35.4575, # 例: 正確な緯度経度を設定
        'longitude': 139.6250, # 例: より正確な住所を設定
        'address': '横浜市神奈川区高島台',
        'type': 'museum',
        'description': '明治時代の陶芸家、宮川香山が製作した作品を展示するミュージアムです。さまざまなモチーフの美しい作品を楽しむことができます。' #
    },
    {
        'id': 'landmark_yokohama_ichiba',
        'name': '横浜市中央卸売市場',
        'latitude': 35.4655, # 例: 正確な緯度経度を設定
        'longitude': 139.6305, # 例: より正確な住所を設定
        'address': '横浜市神奈川区山内町',
        'type': 'market',
        'description': '昭和6年(1931)年に日本で3番目に開設された歴史ある市場で、日本各地から生鮮食料品が集められ、横浜市のみなさんの食卓に届けられています。毎週土曜日(午前8時から午前10時まで)には、一般開放を行っています。' #
    },
    {
        'id': 'landmark_sea_bus',
        'name': 'シーバス乗り場(横浜駅東口ベイクォーター)',
        'latitude': 35.4600, # 例: 正確な緯度経度を設定
        'longitude': 139.6200, # 例: より正確な住所を設定
        'address': '横浜市神奈川区金港町',
        'type': 'transportation',
        'description': 'シーバスは、ベイエリアの名所を水上から眺めながら移動できる海上バスです。ベイクォーターに停泊し、赤レンガや山下公園などへ向け出航します。' #
    },
    {
        'id': 'landmark_hamawing',
        'name': 'ハマウィング',
        'latitude': 35.4590, # 例: 正確な緯度経度を設定
        'longitude': 139.6190, # 例: より正確な住所を設定
        'address': '横浜市神奈川区東扇島',
        'type': 'landmark', # ランドマーク
        'description': '横浜港にある風力発電施設で、羽根の高さは116メートルです。発電量は約210万kWh(キロワットアワー)で、一般家庭約500世帯分の年間電力消費に相当します。(敷地内は立ち入り禁止です。)' #
    },
    {
        'id': 'landmark_ice_arena',
        'name': '横浜銀行アイスアリーナ',
        'latitude': 35.4610, # 例: 正確な緯度経度を設定
        'longitude': 139.6210, # 例: より正確な住所を設定
        'address': '横浜市神奈川区山内町',
        'type': 'sports_facility',
        'description': 'メインリンクとサプリングの2つのスケートリンクがあります。また、スケート教室もしており、一年を通してスケートを楽しむことができます。' #
    },
    {
        'id': 'structure_odaibashi',
        'name': 'お台橋',
        'latitude': 35.4645, # 例: 正確な緯度経度を設定
        'longitude': 139.6300, # 例: より正確な住所を設定
        'address': '横浜市神奈川区山内町',
        'type': 'structure', # 土木・建築遺構
        'description': '滝の川にかかる、市中央市場の門前です。昭和3年(1928)年に完成し、平成14年(2002年)に架けかえられました。当時のデザインが復元され、橋の一部が再利用されています。' #
    },
    {
        'id': 'structure_mizuho_bridge',
        'name': '瑞穂橋りょうと瑞穂橋',
        'latitude': 35.4630, # 例: 正確な緯度経度を設定
        'longitude': 139.6295, # 例: より正確な住所を設定
        'address': '横浜市神奈川区瑞穂',
        'type': 'structure',
        'description': '瑞穂橋りょうは、日本で初めて09年(1934年)につくられました。その設計は、船を造る分野から始まり、橋の技術にも広まっていきました。瑞穂橋は、平成7年(1995年)に架けかえられました。' #
    },
    {
        'id': 'structure_aokimachi_yohheki',
        'name': '青木町付近鉄道よう壁と本覺寺付近よう壁',
        'latitude': 35.4660, # 例: 正確な緯度経度を設定
        'longitude': 139.6335, # 例: より正確な住所を設定
        'address': '横浜市神奈川区青木町',
        'type': 'structure',
        'description': '青木橋の下にあるよう壁は鉄道特有の積よう壁です。本覺寺付近よう壁でも同じ谷積を使用しており、周囲の調和に配慮しているのが特徴です。' #
    },
    {
        'id': 'structure_nissan_guest_hall',
        'name': '日産自動車 横浜工場ゲストホール',
        'latitude': 35.4700, # 例: 正確な緯度経度を設定
        'longitude': 139.6300, # 例: より正確な住所を設定
        'address': '横浜市神奈川区宝町',
        'type': 'building', # 一般的な建物だが、歴史的価値あり
        'description': '当ホールは、市内産一の動画の車ビルとして重要なもので、市の歴史的建造物に指定されています。現在はゲストホールとして利用されており、世代のエンジンを紹介するエンジンミュージアムや、日産自動車の展示を楽しむことができます。' #
    },
    {
        'id': 'landmark_matsunami',
        'name': '松並木',
        'latitude': 35.4680, # 仮の緯度
        'longitude': 139.6365, # 仮の経度
        'address': '横浜市神奈川区台町',
        'type': 'historical_site',
        'description': '地区センターの前の通りは、宿場町だったころの顔を思わせる松並木が戻られるスポットです。松の木は、宿場に陰をつくり、旅人は吹きつける風から旅人を守る役もありました。' #
    },
    {
        'id': 'park_portsite',
        'name': 'ポートサイド公園',
        'latitude': 35.4670, # 仮の緯度
        'longitude': 139.6250, # 仮の経度
        'address': '横浜市神奈川区星野町',
        'type': 'park',
        'description': '周辺に広がるみなとみらいと、シーバスや貨物船の送る航行を眺められるスポットです。国内最大級の芝生などのユニークなデザインを楽しむことができます。' #
    },
    {
        'id': 'park_kougayato_sakura',
        'name': '幸ヶ谷公園の桜',
        'latitude': 35.4690, # 仮の緯度
        'longitude': 139.6385, # 仮の経度
        'address': '横浜市神奈川区幸ケ谷',
        'type': 'park',
        'description': '小高い丘にある公園の敷地いっぱいに桜が植えられ、開花すると一面がピンク色に彩られるスポットです。' #
    },
]


def analyze_location_for_building(latitude: float, longitude: float):
    """
    ユーザーの現在地から、データベースに登録された最も近い歴史的建造物を特定し、返す。
    画像分析は行わない。

    Args:
        latitude: 現在地の緯度
        longitude: 現在地の経度
    """

    # 検索半径（キロメートル）
    SEARCH_RADIUS_KM = 0.050  # 50メートル

    closest_building = None
    min_distance = float('inf')

    # データベースの各建造物をループして、ユーザーの現在地からの距離を計算
    for building_info in HISTORICAL_BUILDINGS_DB:
        building_lat = building_info['latitude']
        building_lon = building_info['longitude']
        distance = calculate_distance(latitude, longitude, building_lat, building_lon)

        # 検索半径内にある最も近い建造物を見つける
        if distance <= SEARCH_RADIUS_KM:
            if distance < min_distance:
                min_distance = distance
                closest_building = building_info

    if closest_building:
        return {
            'category': closest_building['type'],
            'name': closest_building['name'],
            'description': closest_building['description'],
            'address': f"住所: {closest_building['address']} (距離: {min_distance:.2f} km)"
        }
    else:
        return {'error': '半径50m以内に、登録された歴史的建造物が見つかりませんでした。'}