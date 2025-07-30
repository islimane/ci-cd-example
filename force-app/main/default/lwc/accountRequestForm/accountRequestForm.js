import { LightningElement, track } from 'lwc';
import LOGO from '@salesforce/resourceUrl/barcelo_logo_cuestionario';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createAccountRequest from '@salesforce/apex/AccountRequestController.createAccountRequest';
import getHotelNames from '@salesforce/apex/AccountRequestController.getHotelNames';

export default class AccountRequestForm extends LightningElement {
    logoUrl = LOGO;
    customerTypeOptions = [
        { label: '--None--', value: '' },
        { label: 'Agency', value: 'AAVV' },
        { label: 'Company', value: 'EMPRESA' },
        { label: 'Tour Operator', value: 'TTOO' },
        { label: 'Receptive', value: 'RECEPTIVO' },
        { label: 'Reservations Centers', value: 'CENTRAL' }
    ];
    motivationTypeOptions = [
        { label: '--None--', value: '' },
        { label: 'All included resorts', value: 'M01' },
        { label: 'Beaches', value: 'M02' },
        { label: 'Nature', value: 'M03' },
        { label: 'City Breaks', value: 'M04' },
        { label: 'Golf', value: 'M05' },
        { label: 'Diving', value: 'M06' },
        { label: 'Couples and honeymoons', value: 'M07' },
        { label: 'Family and Kids', value: 'M08' },
        { label: 'Seniors', value: 'M09' },
        { label: 'Spa', value: 'M010' },
        { label: 'Casino', value: 'M011' },
        { label: 'Circuits', value: 'M012' },
        { label: 'Fairs', value: 'M013' },
        { label: 'Cycling', value: 'M014' },
        { label: 'Soccer', value: 'M015' },
        { label: 'MICE', value: 'M016' },
        { label: 'Business', value: 'M017' },
        { label: 'Gastronomy', value: 'M018' },
        { label: 'Sports', value: 'M019' },
        { label: 'Snow', value: 'M020' },
        { label: 'Other', value: 'M021' },
        { label: '+55', value: 'M022' },
        { label: 'Audiovisuals', value: 'M023' }
    ];
    marketSegmentOptions = [
        { label: '--None--', value: '' },
        { label: 'Business Group', value: 'Z01' },
        { label: 'Leisure Group', value: 'Z02' },
        { label: 'Individual Business', value: 'Z03' },
        { label: 'Individual Leisure', value: 'Z04' }
    ];
    @track formData = {
        name: '',
        corporateName: '',
        taxNumber: '',
        marketSegment: '',
        motivationType: '',
        customerType: '',
        email: '',
        phone: '',
        mobilePhone: '',
        fax: '',
        country: '',
        street: '',
        postalCode: '',
        city: '',
        state: '',
        requestComments: '',
        addressSearch: '',
        hotel: '',
        userEmail: ''
    };

    @track isSubmitting = false;
    @track showSuccess = false;
    @track errorMessage = '';

    @track hotelOptions = [];

    connectedCallback() {
        getHotelNames()
            .then(result => {
                const map = JSON.parse(result);
                this.hotelOptions = Object.entries(map).map(([value, label]) => ({
                    label,
                    value
                }));
            })
            .catch(error => {
                // Manejo de errores si lo necesitas
                this.hotelOptions = [];
            });
    }

    countryOptions = [
        { label: '--None--', value: '' },
  
  {
    "value": "AD",
    "label": "Andorra",
    "states": [
      {
        "value": "02",
        "label": "Canillo"
      },
      {
        "value": "03",
        "label": "Encamp"
      },
      {
        "value": "04",
        "label": "La Massana"
      },
      {
        "value": "05",
        "label": "Ordino"
      },
      {
        "value": "06",
        "label": "Sant Julià de Lòria"
      },
      {
        "value": "07",
        "label": "Andorra la Vella"
      },
      {
        "value": "08",
        "label": "Escaldes-Engordany"
      }
    ]
  },
  {
    "value": "AE",
    "label": "United Arab Emirates",
    "states": [
      {
        "value": "AJ",
        "label": "‘Ajmān"
      },
      {
        "value": "AZ",
        "label": "Abu Dhabi"
      },
      {
        "value": "DU",
        "label": "Dubai"
      },
      {
        "value": "FU",
        "label": "Fujairah"
      },
      {
        "value": "RK",
        "label": "Ras Al Khaimah"
      },
      {
        "value": "SH",
        "label": "Sharjah"
      },
      {
        "value": "UQ",
        "label": "Umm Al Quwain"
      }
    ]
  },
  {
    "value": "AF",
    "label": "Afghanistan",
    "states": [
      {
        "value": "BAL",
        "label": "Balkh"
      },
      {
        "value": "BAM",
        "label": "Bāmyān"
      },
      {
        "value": "BDG",
        "label": "Bādghīs"
      },
      {
        "value": "BDS",
        "label": "Badakhshān"
      },
      {
        "value": "BGL",
        "label": "Baghlān"
      },
      {
        "value": "DAY",
        "label": "Dāykundī"
      },
      {
        "value": "FRA",
        "label": "Farāh"
      },
      {
        "value": "FYB",
        "label": "Fāryāb"
      },
      {
        "value": "GHA",
        "label": "Ghaznī"
      },
      {
        "value": "GHO",
        "label": "Ghōr"
      },
      {
        "value": "HEL",
        "label": "Helmand"
      },
      {
        "value": "HER",
        "label": "Herāt"
      },
      {
        "value": "JOW",
        "label": "Jowzjān"
      },
      {
        "value": "KAB",
        "label": "Kābul"
      },
      {
        "value": "KAN",
        "label": "Kandahār"
      },
      {
        "value": "KAP",
        "label": "Kāpīsā"
      },
      {
        "value": "KDZ",
        "label": "Kunduz"
      },
      {
        "value": "KHO",
        "label": "Khōst"
      },
      {
        "value": "KNR",
        "label": "Kunaṟ"
      },
      {
        "value": "LAG",
        "label": "Laghmān"
      },
      {
        "value": "LOG",
        "label": "Lōgar"
      },
      {
        "value": "NAN",
        "label": "Nangarhār"
      },
      {
        "value": "NIM",
        "label": "Nīmrōz"
      },
      {
        "value": "NUR",
        "label": "Nūristān"
      },
      {
        "value": "PAN",
        "label": "Panjshayr"
      },
      {
        "value": "PAR",
        "label": "Parwān"
      },
      {
        "value": "PIA",
        "label": "Paktiyā"
      },
      {
        "value": "PKA",
        "label": "Paktīkā"
      },
      {
        "value": "SAM",
        "label": "Samangān"
      },
      {
        "value": "SAR",
        "label": "Sar-e Pul"
      },
      {
        "value": "TAK",
        "label": "Takhār"
      },
      {
        "value": "URU",
        "label": "Uruzgān"
      },
      {
        "value": "WAR",
        "label": "Wardak"
      },
      {
        "value": "ZAB",
        "label": "Zābul"
      }
    ]
  },
  {
    "value": "AG",
    "label": "Antigua and Barbuda",
    "states": [
      {
        "value": "03",
        "label": "Saint George"
      },
      {
        "value": "04",
        "label": "Saint John"
      },
      {
        "value": "05",
        "label": "Saint Mary"
      },
      {
        "value": "06",
        "label": "Saint Paul"
      },
      {
        "value": "07",
        "label": "Saint Peter"
      },
      {
        "value": "08",
        "label": "Saint Philip"
      },
      {
        "value": "10",
        "label": "Barbuda"
      },
      {
        "value": "11",
        "label": "Redonda"
      }
    ]
  },
  {
    "value": "AI",
    "label": "Anguilla",
    "states": []
  },
  {
    "value": "AL",
    "label": "Albania",
    "states": [
      {
        "value": "01",
        "label": "Berat"
      },
      {
        "value": "02",
        "label": "Durrës"
      },
      {
        "value": "03",
        "label": "Elbasan"
      },
      {
        "value": "04",
        "label": "Fier"
      },
      {
        "value": "05",
        "label": "Gjirokastër"
      },
      {
        "value": "06",
        "label": "Korçë"
      },
      {
        "value": "07",
        "label": "Kukës"
      },
      {
        "value": "08",
        "label": "Lezhë"
      },
      {
        "value": "09",
        "label": "Dibër"
      },
      {
        "value": "10",
        "label": "Shkodër"
      },
      {
        "value": "11",
        "label": "Tiranë"
      },
      {
        "value": "12",
        "label": "Vlorë"
      }
    ]
  },
  {
    "value": "AM",
    "label": "Armenia",
    "states": [
      {
        "value": "AG",
        "label": "Aragac̣otn"
      },
      {
        "value": "AR",
        "label": "Ararat"
      },
      {
        "value": "AV",
        "label": "Armavir"
      },
      {
        "value": "ER",
        "label": "Erevan"
      },
      {
        "value": "GR",
        "label": "Geġark'unik'"
      },
      {
        "value": "KT",
        "label": "Kotayk'"
      },
      {
        "value": "LO",
        "label": "Loṙi"
      },
      {
        "value": "SH",
        "label": "Širak"
      },
      {
        "value": "SU",
        "label": "Syunik'"
      },
      {
        "value": "TV",
        "label": "Tavuš"
      },
      {
        "value": "VD",
        "label": "Vayoć Jor"
      }
    ]
  },
  {
    "value": "AO",
    "label": "Angola",
    "states": [
      {
        "value": "BGO",
        "label": "Bengo"
      },
      {
        "value": "BGU",
        "label": "Benguela"
      },
      {
        "value": "BIE",
        "label": "Bié"
      },
      {
        "value": "CAB",
        "label": "Cabinda"
      },
      {
        "value": "CCU",
        "label": "Kuando Kubango"
      },
      {
        "value": "CNN",
        "label": "Cunene"
      },
      {
        "value": "CNO",
        "label": "Kwanza Norte"
      },
      {
        "value": "CUS",
        "label": "Kwanza Sul"
      },
      {
        "value": "HUA",
        "label": "Huambo"
      },
      {
        "value": "HUI",
        "label": "Huíla"
      },
      {
        "value": "LNO",
        "label": "Lunda-Norte"
      },
      {
        "value": "LSU",
        "label": "Lunda-Sul"
      },
      {
        "value": "LUA",
        "label": "Luanda"
      },
      {
        "value": "MAL",
        "label": "Malange"
      },
      {
        "value": "MOX",
        "label": "Moxico"
      },
      {
        "value": "NAM",
        "label": "Namibe"
      },
      {
        "value": "UIG",
        "label": "Uíge"
      },
      {
        "value": "ZAI",
        "label": "Zaire"
      }
    ]
  },
  {
    "value": "AQ",
    "label": "Antarctica",
    "states": []
  },
  {
    "value": "AR",
    "label": "Argentina",
    "states": [
      {
        "value": "A",
        "label": "Salta"
      },
      {
        "value": "B",
        "label": "Buenos Aires"
      },
      {
        "value": "C",
        "label": "Ciudad Autónoma de Buenos Aires"
      },
      {
        "value": "D",
        "label": "San Luis"
      },
      {
        "value": "E",
        "label": "Entre Ríos"
      },
      {
        "value": "F",
        "label": "La Rioja"
      },
      {
        "value": "G",
        "label": "Santiago del Estero"
      },
      {
        "value": "H",
        "label": "Chaco"
      },
      {
        "value": "J",
        "label": "San Juan"
      },
      {
        "value": "K",
        "label": "Catamarca"
      },
      {
        "value": "L",
        "label": "La Pampa"
      },
      {
        "value": "M",
        "label": "Mendoza"
      },
      {
        "value": "N",
        "label": "Misiones"
      },
      {
        "value": "P",
        "label": "Formosa"
      },
      {
        "value": "Q",
        "label": "Neuquén"
      },
      {
        "value": "R",
        "label": "Río Negro"
      },
      {
        "value": "S",
        "label": "Santa Fe"
      },
      {
        "value": "T",
        "label": "Tucumán"
      },
      {
        "value": "U",
        "label": "Chubut"
      },
      {
        "value": "V",
        "label": "Tierra del Fuego"
      },
      {
        "value": "W",
        "label": "Corrientes"
      },
      {
        "value": "X",
        "label": "Córdoba"
      },
      {
        "value": "Y",
        "label": "Jujuy"
      },
      {
        "value": "Z",
        "label": "Santa Cruz"
      }
    ]
  },
  {
    "value": "AT",
    "label": "Austria",
    "states": [
      {
        "value": "1",
        "label": "Burgenland"
      },
      {
        "value": "2",
        "label": "Kärnten"
      },
      {
        "value": "3",
        "label": "Niederösterreich"
      },
      {
        "value": "4",
        "label": "Oberösterreich"
      },
      {
        "value": "5",
        "label": "Salzburg"
      },
      {
        "value": "6",
        "label": "Steiermark"
      },
      {
        "value": "7",
        "label": "Tirol"
      },
      {
        "value": "8",
        "label": "Vorarlberg"
      },
      {
        "value": "9",
        "label": "Wien"
      }
    ]
  },
  {
    "value": "AU",
    "label": "Australia",
    "states": [
      {
        "value": "ACT",
        "label": "Australian Capital Territory"
      },
      {
        "value": "NSW",
        "label": "New South Wales"
      },
      {
        "value": "NT",
        "label": "Northern Territory"
      },
      {
        "value": "QLD",
        "label": "Queensland"
      },
      {
        "value": "SA",
        "label": "South Australia"
      },
      {
        "value": "TAS",
        "label": "Tasmania"
      },
      {
        "value": "VIC",
        "label": "Victoria"
      },
      {
        "value": "WA",
        "label": "Western Australia"
      }
    ]
  },
  {
    "value": "AW",
    "label": "Aruba",
    "states": []
  },
  {
    "value": "AX",
    "label": "Aland Islands",
    "states": []
  },
  {
    "value": "AZ",
    "label": "Azerbaijan",
    "states": [
      {
        "value": "ABS",
        "label": "Abşeron"
      },
      {
        "value": "AGA",
        "label": "Ağstafa"
      },
      {
        "value": "AGC",
        "label": "Ağcabədi"
      },
      {
        "value": "AGM",
        "label": "Ağdam"
      },
      {
        "value": "AGS",
        "label": "Ağdaş"
      },
      {
        "value": "AGU",
        "label": "Ağsu"
      },
      {
        "value": "AST",
        "label": "Astara"
      },
      {
        "value": "BA",
        "label": "Bakı"
      },
      {
        "value": "BAB",
        "label": "Babək"
      },
      {
        "value": "BAL",
        "label": "Balakən"
      },
      {
        "value": "BAR",
        "label": "Bərdə"
      },
      {
        "value": "BEY",
        "label": "Beyləqan"
      },
      {
        "value": "BIL",
        "label": "Biləsuvar"
      },
      {
        "value": "CAB",
        "label": "Cəbrayıl"
      },
      {
        "value": "CAL",
        "label": "Cəlilabad"
      },
      {
        "value": "CUL",
        "label": "Culfa"
      },
      {
        "value": "DAS",
        "label": "Daşkəsən"
      },
      {
        "value": "FUZ",
        "label": "Füzuli"
      },
      {
        "value": "GA",
        "label": "Gəncə"
      },
      {
        "value": "GAD",
        "label": "Gədəbəy"
      },
      {
        "value": "GOR",
        "label": "Goranboy"
      },
      {
        "value": "GOY",
        "label": "Göyçay"
      },
      {
        "value": "GYG",
        "label": "Göygöl"
      },
      {
        "value": "HAC",
        "label": "Hacıqabul"
      },
      {
        "value": "IMI",
        "label": "İmişli"
      },
      {
        "value": "ISM",
        "label": "İsmayıllı"
      },
      {
        "value": "KAL",
        "label": "Kəlbəcər"
      },
      {
        "value": "KAN",
        "label": "Kǝngǝrli"
      },
      {
        "value": "KUR",
        "label": "Kürdəmir"
      },
      {
        "value": "LAC",
        "label": "Laçın"
      },
      {
        "value": "LAN",
        "label": "Lənkəran"
      },
      {
        "value": "LER",
        "label": "Lerik"
      },
      {
        "value": "MAS",
        "label": "Masallı"
      },
      {
        "value": "MI",
        "label": "Mingəçevir"
      },
      {
        "value": "NA",
        "label": "Naftalan"
      },
      {
        "value": "NEF",
        "label": "Neftçala"
      },
      {
        "value": "NX",
        "label": "Naxçıvan"
      },
      {
        "value": "OGU",
        "label": "Oğuz"
      },
      {
        "value": "ORD",
        "label": "Ordubad"
      },
      {
        "value": "QAB",
        "label": "Qəbələ"
      },
      {
        "value": "QAX",
        "label": "Qax"
      },
      {
        "value": "QAZ",
        "label": "Qazax"
      },
      {
        "value": "QBA",
        "label": "Quba"
      },
      {
        "value": "QBI",
        "label": "Qubadlı"
      },
      {
        "value": "QOB",
        "label": "Qobustan"
      },
      {
        "value": "QUS",
        "label": "Qusar"
      },
      {
        "value": "SAB",
        "label": "Sabirabad"
      },
      {
        "value": "SAD",
        "label": "Sədərək"
      },
      {
        "value": "SAH",
        "label": "Şahbuz"
      },
      {
        "value": "SAK",
        "label": "Şəki"
      },
      {
        "value": "SAL",
        "label": "Salyan"
      },
      {
        "value": "SAR",
        "label": "Şərur"
      },
      {
        "value": "SAT",
        "label": "Saatlı"
      },
      {
        "value": "SBN",
        "label": "Şabran"
      },
      {
        "value": "SIY",
        "label": "Siyəzən"
      },
      {
        "value": "SKR",
        "label": "Şəmkir"
      },
      {
        "value": "SM",
        "label": "Sumqayıt"
      },
      {
        "value": "SMI",
        "label": "Şamaxı"
      },
      {
        "value": "SMX",
        "label": "Samux"
      },
      {
        "value": "SR",
        "label": "Şirvan"
      },
      {
        "value": "SUS",
        "label": "Şuşa"
      },
      {
        "value": "TAR",
        "label": "Tərtər"
      },
      {
        "value": "TOV",
        "label": "Tovuz"
      },
      {
        "value": "UCA",
        "label": "Ucar"
      },
      {
        "value": "XA",
        "label": "Xankəndi"
      },
      {
        "value": "XAC",
        "label": "Xaçmaz"
      },
      {
        "value": "XCI",
        "label": "Xocalı"
      },
      {
        "value": "XIZ",
        "label": "Xızı"
      },
      {
        "value": "XVD",
        "label": "Xocavənd"
      },
      {
        "value": "YAR",
        "label": "Yardımlı"
      },
      {
        "value": "YEV",
        "label": "Yevlax"
      },
      {
        "value": "ZAN",
        "label": "Zəngilan"
      },
      {
        "value": "ZAQ",
        "label": "Zaqatala"
      },
      {
        "value": "ZAR",
        "label": "Zərdab"
      }
    ]
  },
  {
    "value": "BA",
    "label": "Bosnia and Herzegovina",
    "states": [
      {
        "value": "BIH",
        "label": "Federacija Bosne i Hercegovine"
      },
      {
        "value": "BRC",
        "label": "Brčko distrikt"
      },
      {
        "value": "SRP",
        "label": "Republika Srpska"
      }
    ]
  },
  {
    "value": "BB",
    "label": "Barbados",
    "states": [
      {
        "value": "01",
        "label": "Christ Church"
      },
      {
        "value": "02",
        "label": "Saint Andrew"
      },
      {
        "value": "03",
        "label": "Saint George"
      },
      {
        "value": "04",
        "label": "Saint James"
      },
      {
        "value": "05",
        "label": "Saint John"
      },
      {
        "value": "06",
        "label": "Saint Joseph"
      },
      {
        "value": "07",
        "label": "Saint Lucy"
      },
      {
        "value": "08",
        "label": "Saint Michael"
      },
      {
        "value": "09",
        "label": "Saint Peter"
      },
      {
        "value": "10",
        "label": "Saint Philip"
      },
      {
        "value": "11",
        "label": "Saint Thomas"
      }
    ]
  },
  {
    "value": "BD",
    "label": "Bangladesh",
    "states": [
      {
        "value": "01",
        "label": "Bandarban"
      },
      {
        "value": "02",
        "label": "Barguna"
      },
      {
        "value": "03",
        "label": "Bogura"
      },
      {
        "value": "04",
        "label": "Brahmanbaria"
      },
      {
        "value": "05",
        "label": "Bagerhat"
      },
      {
        "value": "07",
        "label": "Bhola"
      },
      {
        "value": "08",
        "label": "Cumilla"
      },
      {
        "value": "09",
        "label": "Chandpur"
      },
      {
        "value": "11",
        "label": "Cox's Bazar"
      },
      {
        "value": "12",
        "label": "Chuadanga"
      },
      {
        "value": "14",
        "label": "Dinajpur"
      },
      {
        "value": "15",
        "label": "Faridpur"
      },
      {
        "value": "16",
        "label": "Feni"
      },
      {
        "value": "17",
        "label": "Gopalganj"
      },
      {
        "value": "18",
        "label": "Gazipur"
      },
      {
        "value": "19",
        "label": "Gaibandha"
      },
      {
        "value": "20",
        "label": "Habiganj"
      },
      {
        "value": "21",
        "label": "Jamalpur"
      },
      {
        "value": "22",
        "label": "Jashore"
      },
      {
        "value": "23",
        "label": "Jhenaidah"
      },
      {
        "value": "24",
        "label": "Joypurhat"
      },
      {
        "value": "25",
        "label": "Jhalakathi"
      },
      {
        "value": "26",
        "label": "Kishoreganj"
      },
      {
        "value": "28",
        "label": "Kurigram"
      },
      {
        "value": "29",
        "label": "Khagrachhari"
      },
      {
        "value": "30",
        "label": "Kushtia"
      },
      {
        "value": "31",
        "label": "Lakshmipur"
      },
      {
        "value": "32",
        "label": "Lalmonirhat"
      },
      {
        "value": "33",
        "label": "Manikganj"
      },
      {
        "value": "35",
        "label": "Munshiganj"
      },
      {
        "value": "36",
        "label": "Madaripur"
      },
      {
        "value": "37",
        "label": "Magura"
      },
      {
        "value": "38",
        "label": "Moulvibazar"
      },
      {
        "value": "39",
        "label": "Meherpur"
      },
      {
        "value": "40",
        "label": "Narayanganj"
      },
      {
        "value": "41",
        "label": "Netrakona"
      },
      {
        "value": "42",
        "label": "Narsingdi"
      },
      {
        "value": "43",
        "label": "Narail"
      },
      {
        "value": "44",
        "label": "Natore"
      },
      {
        "value": "45",
        "label": "Chapai Nawabganj"
      },
      {
        "value": "46",
        "label": "Nilphamari"
      },
      {
        "value": "47",
        "label": "Noakhali"
      },
      {
        "value": "48",
        "label": "Naogaon"
      },
      {
        "value": "49",
        "label": "Pabna"
      },
      {
        "value": "50",
        "label": "Pirojpur"
      },
      {
        "value": "51",
        "label": "Patuakhali"
      },
      {
        "value": "52",
        "label": "Panchagarh"
      },
      {
        "value": "53",
        "label": "Rajbari"
      },
      {
        "value": "56",
        "label": "Rangamati"
      },
      {
        "value": "57",
        "label": "Sherpur"
      },
      {
        "value": "58",
        "label": "Satkhira"
      },
      {
        "value": "59",
        "label": "Sirajganj"
      },
      {
        "value": "61",
        "label": "Sunamganj"
      },
      {
        "value": "62",
        "label": "Shariatpur"
      },
      {
        "value": "63",
        "label": "Tangail"
      },
      {
        "value": "64",
        "label": "Thakurgaon"
      },
      {
        "value": "A",
        "label": "Barishal"
      },
      {
        "value": "B",
        "label": "Chittagong"
      },
      {
        "value": "C",
        "label": "Dhaka"
      },
      {
        "value": "D",
        "label": "Khulna"
      },
      {
        "value": "E",
        "label": "Rajshahi"
      },
      {
        "value": "F",
        "label": "Rangpur"
      },
      {
        "value": "G",
        "label": "Sylhet"
      },
      {
        "value": "H",
        "label": "Mymensingh"
      }
    ]
  },
  {
    "value": "BE",
    "label": "Belgium",
    "states": [
      {
        "value": "BRU",
        "label": "Brussels"
      },
      {
        "value": "VAN",
        "label": "Antwerpen"
      },
      {
        "value": "VBR",
        "label": "Vlaams-Brabant"
      },
      {
        "value": "VLG",
        "label": "Vlaams Gewest"
      },
      {
        "value": "VLI",
        "label": "Limburg"
      },
      {
        "value": "VOV",
        "label": "Oost-Vlaanderen"
      },
      {
        "value": "VWV",
        "label": "West-Vlaanderen"
      },
      {
        "value": "WAL",
        "label": "wallonne, Région"
      },
      {
        "value": "WBR",
        "label": "Brabant wallon"
      },
      {
        "value": "WHT",
        "label": "Hainaut"
      },
      {
        "value": "WLG",
        "label": "Liège"
      },
      {
        "value": "WLX",
        "label": "Luxembourg"
      },
      {
        "value": "WNA",
        "label": "Namur"
      }
    ]
  },
  {
    "value": "BF",
    "label": "Burkina Faso",
    "states": [
      {
        "value": "01",
        "label": "Boucle du Mouhoun"
      },
      {
        "value": "02",
        "label": "Cascades"
      },
      {
        "value": "03",
        "label": "Centre"
      },
      {
        "value": "04",
        "label": "Centre-Est"
      },
      {
        "value": "05",
        "label": "Centre-Nord"
      },
      {
        "value": "06",
        "label": "Centre-Ouest"
      },
      {
        "value": "07",
        "label": "Centre-Sud"
      },
      {
        "value": "08",
        "label": "Est"
      },
      {
        "value": "09",
        "label": "Hauts-Bassins"
      },
      {
        "value": "10",
        "label": "Nord"
      },
      {
        "value": "11",
        "label": "Plateau-Central"
      },
      {
        "value": "12",
        "label": "Sahel"
      },
      {
        "value": "13",
        "label": "Sud-Ouest"
      },
      {
        "value": "BAL",
        "label": "Balé"
      },
      {
        "value": "BAM",
        "label": "Bam"
      },
      {
        "value": "BAN",
        "label": "Banwa"
      },
      {
        "value": "BAZ",
        "label": "Bazèga"
      },
      {
        "value": "BGR",
        "label": "Bougouriba"
      },
      {
        "value": "BLG",
        "label": "Boulgou"
      },
      {
        "value": "BLK",
        "label": "Boulkiemdé"
      },
      {
        "value": "COM",
        "label": "Comoé"
      },
      {
        "value": "GAN",
        "label": "Ganzourgou"
      },
      {
        "value": "GNA",
        "label": "Gnagna"
      },
      {
        "value": "GOU",
        "label": "Gourma"
      },
      {
        "value": "HOU",
        "label": "Houet"
      },
      {
        "value": "IOB",
        "label": "Ioba"
      },
      {
        "value": "KAD",
        "label": "Kadiogo"
      },
      {
        "value": "KEN",
        "label": "Kénédougou"
      },
      {
        "value": "KMD",
        "label": "Komondjari"
      },
      {
        "value": "KMP",
        "label": "Kompienga"
      },
      {
        "value": "KOP",
        "label": "Koulpélogo"
      },
      {
        "value": "KOS",
        "label": "Kossi"
      },
      {
        "value": "KOT",
        "label": "Kouritenga"
      },
      {
        "value": "KOW",
        "label": "Kourwéogo"
      },
      {
        "value": "LER",
        "label": "Léraba"
      },
      {
        "value": "LOR",
        "label": "Loroum"
      },
      {
        "value": "MOU",
        "label": "Mouhoun"
      },
      {
        "value": "NAM",
        "label": "Namentenga"
      },
      {
        "value": "NAO",
        "label": "Nahouri"
      },
      {
        "value": "NAY",
        "label": "Nayala"
      },
      {
        "value": "NOU",
        "label": "Noumbiel"
      },
      {
        "value": "OUB",
        "label": "Oubritenga"
      },
      {
        "value": "OUD",
        "label": "Oudalan"
      },
      {
        "value": "PAS",
        "label": "Passoré"
      },
      {
        "value": "PON",
        "label": "Poni"
      },
      {
        "value": "SEN",
        "label": "Séno"
      },
      {
        "value": "SIS",
        "label": "Sissili"
      },
      {
        "value": "SMT",
        "label": "Sanmatenga"
      },
      {
        "value": "SNG",
        "label": "Sanguié"
      },
      {
        "value": "SOM",
        "label": "Soum"
      },
      {
        "value": "SOR",
        "label": "Sourou"
      },
      {
        "value": "TAP",
        "label": "Tapoa"
      },
      {
        "value": "TUI",
        "label": "Tuy"
      },
      {
        "value": "YAG",
        "label": "Yagha"
      },
      {
        "value": "YAT",
        "label": "Yatenga"
      },
      {
        "value": "ZIR",
        "label": "Ziro"
      },
      {
        "value": "ZON",
        "label": "Zondoma"
      },
      {
        "value": "ZOU",
        "label": "Zoundwéogo"
      }
    ]
  },
  {
    "value": "BG",
    "label": "Bulgaria",
    "states": [
      {
        "value": "01",
        "label": "Blagoevgrad"
      },
      {
        "value": "02",
        "label": "Burgas"
      },
      {
        "value": "03",
        "label": "Varna"
      },
      {
        "value": "04",
        "label": "Veliko Tarnovo"
      },
      {
        "value": "05",
        "label": "Vidin"
      },
      {
        "value": "06",
        "label": "Vratsa"
      },
      {
        "value": "07",
        "label": "Gabrovo"
      },
      {
        "value": "08",
        "label": "Dobrich"
      },
      {
        "value": "09",
        "label": "Kardzhali"
      },
      {
        "value": "10",
        "label": "Kyustendil"
      },
      {
        "value": "11",
        "label": "Lovech"
      },
      {
        "value": "12",
        "label": "Montana"
      },
      {
        "value": "13",
        "label": "Pazardzhik"
      },
      {
        "value": "14",
        "label": "Pernik"
      },
      {
        "value": "15",
        "label": "Pleven"
      },
      {
        "value": "16",
        "label": "Plovdiv"
      },
      {
        "value": "17",
        "label": "Razgrad"
      },
      {
        "value": "18",
        "label": "Ruse"
      },
      {
        "value": "19",
        "label": "Silistra"
      },
      {
        "value": "20",
        "label": "Sliven"
      },
      {
        "value": "21",
        "label": "Smolyan"
      },
      {
        "value": "22",
        "label": "Sofia (stolitsa)"
      },
      {
        "value": "23",
        "label": "Sofia"
      },
      {
        "value": "24",
        "label": "Stara Zagora"
      },
      {
        "value": "25",
        "label": "Targovishte"
      },
      {
        "value": "26",
        "label": "Haskovo"
      },
      {
        "value": "27",
        "label": "Shumen"
      },
      {
        "value": "28",
        "label": "Yambol"
      }
    ]
  },
  {
    "value": "BH",
    "label": "Bahrain",
    "states": [
      {
        "value": "13",
        "label": "Al Manāmah"
      },
      {
        "value": "14",
        "label": "Al Janūbīyah"
      },
      {
        "value": "15",
        "label": "Al Muḩarraq"
      },
      {
        "value": "17",
        "label": "Ash Shamālīyah"
      }
    ]
  },
  {
    "value": "BI",
    "label": "Burundi",
    "states": [
      {
        "value": "BB",
        "label": "Bubanza"
      },
      {
        "value": "BL",
        "label": "Bujumbura Rural"
      },
      {
        "value": "BM",
        "label": "Bujumbura Mairie"
      },
      {
        "value": "BR",
        "label": "Bururi"
      },
      {
        "value": "CA",
        "label": "Cankuzo"
      },
      {
        "value": "CI",
        "label": "Cibitoke"
      },
      {
        "value": "GI",
        "label": "Gitega"
      },
      {
        "value": "KI",
        "label": "Kirundo"
      },
      {
        "value": "KR",
        "label": "Karuzi"
      },
      {
        "value": "KY",
        "label": "Kayanza"
      },
      {
        "value": "MA",
        "label": "Makamba"
      },
      {
        "value": "MU",
        "label": "Muramvya"
      },
      {
        "value": "MW",
        "label": "Mwaro"
      },
      {
        "value": "MY",
        "label": "Muyinga"
      },
      {
        "value": "NG",
        "label": "Ngozi"
      },
      {
        "value": "RM",
        "label": "Rumonge"
      },
      {
        "value": "RT",
        "label": "Rutana"
      },
      {
        "value": "RY",
        "label": "Ruyigi"
      }
    ]
  },
  {
    "value": "BJ",
    "label": "Benin",
    "states": [
      {
        "value": "AK",
        "label": "Atacora"
      },
      {
        "value": "AL",
        "label": "Alibori"
      },
      {
        "value": "AQ",
        "label": "Atlantique"
      },
      {
        "value": "BO",
        "label": "Borgou"
      },
      {
        "value": "CO",
        "label": "Collines"
      },
      {
        "value": "DO",
        "label": "Donga"
      },
      {
        "value": "KO",
        "label": "Couffo"
      },
      {
        "value": "LI",
        "label": "Littoral"
      },
      {
        "value": "MO",
        "label": "Mono"
      },
      {
        "value": "OU",
        "label": "Ouémé"
      },
      {
        "value": "PL",
        "label": "Plateau"
      },
      {
        "value": "ZO",
        "label": "Zou"
      }
    ]
  },
  {
    "value": "BL",
    "label": "Saint Barthélemy",
    "states": []
  },
  {
    "value": "BM",
    "label": "Bermuda",
    "states": []
  },
  {
    "value": "BN",
    "label": "Brunei Darussalam",
    "states": [
      {
        "value": "BE",
        "label": "Belait"
      },
      {
        "value": "BM",
        "label": "Brunei-Muara"
      },
      {
        "value": "TE",
        "label": "Temburong"
      },
      {
        "value": "TU",
        "label": "Tutong"
      }
    ]
  },
  {
    "value": "BO",
    "label": "Bolivia, Plurinational State of",
    "states": [
      {
        "value": "B",
        "label": "El Beni"
      },
      {
        "value": "C",
        "label": "Cochabamba"
      },
      {
        "value": "H",
        "label": "Chuquisaca"
      },
      {
        "value": "L",
        "label": "La Paz"
      },
      {
        "value": "N",
        "label": "Pando"
      },
      {
        "value": "O",
        "label": "Oruro"
      },
      {
        "value": "P",
        "label": "Potosí"
      },
      {
        "value": "S",
        "label": "Santa Cruz"
      },
      {
        "value": "T",
        "label": "Tarija"
      }
    ]
  },
  {
    "value": "BQ",
    "label": "Bonaire, Sint Eustatius and Saba",
    "states": [
      {
        "value": "BO",
        "label": "Bonaire"
      },
      {
        "value": "SA",
        "label": "Saba"
      },
      {
        "value": "SE",
        "label": "Sint Eustatius"
      }
    ]
  },
  {
    "value": "BR",
    "label": "Brazil",
    "states": [
      {
        "value": "AC",
        "label": "Acre"
      },
      {
        "value": "AL",
        "label": "Alagoas"
      },
      {
        "value": "AM",
        "label": "Amazonas"
      },
      {
        "value": "AP",
        "label": "Amapá"
      },
      {
        "value": "BA",
        "label": "Bahia"
      },
      {
        "value": "CE",
        "label": "Ceará"
      },
      {
        "value": "DF",
        "label": "Distrito Federal"
      },
      {
        "value": "ES",
        "label": "Espírito Santo"
      },
      {
        "value": "GO",
        "label": "Goiás"
      },
      {
        "value": "MA",
        "label": "Maranhão"
      },
      {
        "value": "MG",
        "label": "Minas Gerais"
      },
      {
        "value": "MS",
        "label": "Mato Grosso do Sul"
      },
      {
        "value": "MT",
        "label": "Mato Grosso"
      },
      {
        "value": "PA",
        "label": "Pará"
      },
      {
        "value": "PB",
        "label": "Paraíba"
      },
      {
        "value": "PE",
        "label": "Pernambuco"
      },
      {
        "value": "PI",
        "label": "Piauí"
      },
      {
        "value": "PR",
        "label": "Paraná"
      },
      {
        "value": "RJ",
        "label": "Rio de Janeiro"
      },
      {
        "value": "RN",
        "label": "Rio Grande do Norte"
      },
      {
        "value": "RO",
        "label": "Rondônia"
      },
      {
        "value": "RR",
        "label": "Roraima"
      },
      {
        "value": "RS",
        "label": "Rio Grande do Sul"
      },
      {
        "value": "SC",
        "label": "Santa Catarina"
      },
      {
        "value": "SE",
        "label": "Sergipe"
      },
      {
        "value": "SP",
        "label": "São Paulo"
      },
      {
        "value": "TO",
        "label": "Tocantins"
      }
    ]
  },
  {
    "value": "BS",
    "label": "Bahamas",
    "states": [
      {
        "value": "AK",
        "label": "Acklins"
      },
      {
        "value": "BI",
        "label": "Bimini"
      },
      {
        "value": "BP",
        "label": "Black Point"
      },
      {
        "value": "BY",
        "label": "Berry Islands"
      },
      {
        "value": "CE",
        "label": "Central Eleuthera"
      },
      {
        "value": "CI",
        "label": "Cat Island"
      },
      {
        "value": "CK",
        "label": "Crooked Island and Long Cay"
      },
      {
        "value": "CO",
        "label": "Central Abaco"
      },
      {
        "value": "CS",
        "label": "Central Andros"
      },
      {
        "value": "EG",
        "label": "East Grand Bahama"
      },
      {
        "value": "EX",
        "label": "Exuma"
      },
      {
        "value": "FP",
        "label": "City of Freeport"
      },
      {
        "value": "GC",
        "label": "Grand Cay"
      },
      {
        "value": "HI",
        "label": "Harbour Island"
      },
      {
        "value": "HT",
        "label": "Hope Town"
      },
      {
        "value": "IN",
        "label": "Inagua"
      },
      {
        "value": "LI",
        "label": "Long Island"
      },
      {
        "value": "MC",
        "label": "Mangrove Cay"
      },
      {
        "value": "MG",
        "label": "Mayaguana"
      },
      {
        "value": "MI",
        "label": "Moore's Island"
      },
      {
        "value": "NE",
        "label": "North Eleuthera"
      },
      {
        "value": "NO",
        "label": "North Abaco"
      },
      {
        "value": "NP",
        "label": "New Providence"
      },
      {
        "value": "NS",
        "label": "North Andros"
      },
      {
        "value": "RC",
        "label": "Rum Cay"
      },
      {
        "value": "RI",
        "label": "Ragged Island"
      },
      {
        "value": "SA",
        "label": "South Andros"
      },
      {
        "value": "SE",
        "label": "South Eleuthera"
      },
      {
        "value": "SO",
        "label": "South Abaco"
      },
      {
        "value": "SS",
        "label": "San Salvador"
      },
      {
        "value": "SW",
        "label": "Spanish Wells"
      },
      {
        "value": "WG",
        "label": "West Grand Bahama"
      }
    ]
  },
  {
    "value": "BT",
    "label": "Bhutan",
    "states": [
      {
        "value": "11",
        "label": "Paro"
      },
      {
        "value": "12",
        "label": "Chhukha"
      },
      {
        "value": "13",
        "label": "Haa"
      },
      {
        "value": "14",
        "label": "Samtse"
      },
      {
        "value": "15",
        "label": "Thimphu"
      },
      {
        "value": "21",
        "label": "Tsirang"
      },
      {
        "value": "22",
        "label": "Dagana"
      },
      {
        "value": "23",
        "label": "Punakha"
      },
      {
        "value": "24",
        "label": "Wangdue Phodrang"
      },
      {
        "value": "31",
        "label": "Sarpang"
      },
      {
        "value": "32",
        "label": "Trongsa"
      },
      {
        "value": "33",
        "label": "Bumthang"
      },
      {
        "value": "34",
        "label": "Zhemgang"
      },
      {
        "value": "41",
        "label": "Trashigang"
      },
      {
        "value": "42",
        "label": "Monggar"
      },
      {
        "value": "43",
        "label": "Pema Gatshel"
      },
      {
        "value": "44",
        "label": "Lhuentse"
      },
      {
        "value": "45",
        "label": "Samdrup Jongkhar"
      },
      {
        "value": "GA",
        "label": "Gasa"
      },
      {
        "value": "TY",
        "label": "Trashi Yangtse"
      }
    ]
  },
  {
    "value": "BV",
    "label": "Bouvet Island",
    "states": []
  },
  {
    "value": "BW",
    "label": "Botswana",
    "states": [
      {
        "value": "CE",
        "label": "Central"
      },
      {
        "value": "CH",
        "label": "Chobe"
      },
      {
        "value": "FR",
        "label": "Francistown"
      },
      {
        "value": "GA",
        "label": "Gaborone"
      },
      {
        "value": "GH",
        "label": "Ghanzi"
      },
      {
        "value": "JW",
        "label": "Jwaneng"
      },
      {
        "value": "KG",
        "label": "Kgalagadi"
      },
      {
        "value": "KL",
        "label": "Kgatleng"
      },
      {
        "value": "KW",
        "label": "Kweneng"
      },
      {
        "value": "LO",
        "label": "Lobatse"
      },
      {
        "value": "NE",
        "label": "North East"
      },
      {
        "value": "NW",
        "label": "North West"
      },
      {
        "value": "SE",
        "label": "South East"
      },
      {
        "value": "SO",
        "label": "Southern"
      },
      {
        "value": "SP",
        "label": "Selibe Phikwe"
      },
      {
        "value": "ST",
        "label": "Sowa Town"
      }
    ]
  },
  {
    "value": "BY",
    "label": "Belarus",
    "states": [
      {
        "value": "BR",
        "label": "Brestskaya voblasts'"
      },
      {
        "value": "HM",
        "label": "Horad Minsk"
      },
      {
        "value": "HO",
        "label": "Homyel'skaya voblasts'"
      },
      {
        "value": "HR",
        "label": "Hrodzyenskaya voblasts'"
      },
      {
        "value": "MA",
        "label": "Mahilyowskaya voblasts'"
      },
      {
        "value": "MI",
        "label": "Minskaya voblasts'"
      },
      {
        "value": "VI",
        "label": "Vitsyebskaya voblasts'"
      }
    ]
  },
  {
    "value": "BZ",
    "label": "Belize",
    "states": [
      {
        "value": "BZ",
        "label": "Belize"
      },
      {
        "value": "CY",
        "label": "Cayo"
      },
      {
        "value": "CZL",
        "label": "Corozal"
      },
      {
        "value": "OW",
        "label": "Orange Walk"
      },
      {
        "value": "SC",
        "label": "Stann Creek"
      },
      {
        "value": "TOL",
        "label": "Toledo"
      }
    ]
  },
  {
    "value": "CA",
    "label": "Canada",
    "states": [
      {
        "value": "AB",
        "label": "Alberta"
      },
      {
        "value": "BC",
        "label": "British Columbia"
      },
      {
        "value": "MB",
        "label": "Manitoba"
      },
      {
        "value": "NB",
        "label": "New Brunswick"
      },
      {
        "value": "NL",
        "label": "Newfoundland and Labrador"
      },
      {
        "value": "NS",
        "label": "Nova Scotia"
      },
      {
        "value": "NT",
        "label": "Northwest Territories"
      },
      {
        "value": "NU",
        "label": "Nunavut"
      },
      {
        "value": "ON",
        "label": "Ontario"
      },
      {
        "value": "PE",
        "label": "Prince Edward Island"
      },
      {
        "value": "QC",
        "label": "Quebec"
      },
      {
        "value": "SK",
        "label": "Saskatchewan"
      },
      {
        "value": "YT",
        "label": "Yukon Territories"
      }
    ]
  },
  {
    "value": "CC",
    "label": "Cocos (Keeling) Islands",
    "states": []
  },
  {
    "value": "CD",
    "label": "Congo, the Democratic Republic of the",
    "states": [
      {
        "value": "BC",
        "label": "Kongo Central"
      },
      {
        "value": "BU",
        "label": "Bas-Uélé"
      },
      {
        "value": "EQ",
        "label": "Équateur"
      },
      {
        "value": "HK",
        "label": "Haut-Katanga"
      },
      {
        "value": "HL",
        "label": "Haut-Lomami"
      },
      {
        "value": "HU",
        "label": "Haut-Uélé"
      },
      {
        "value": "IT",
        "label": "Ituri"
      },
      {
        "value": "KC",
        "label": "Kasaï Central"
      },
      {
        "value": "KE",
        "label": "Kasaï Oriental"
      },
      {
        "value": "KG",
        "label": "Kwango"
      },
      {
        "value": "KL",
        "label": "Kwilu"
      },
      {
        "value": "KN",
        "label": "Kinshasa"
      },
      {
        "value": "KS",
        "label": "Kasaï"
      },
      {
        "value": "LO",
        "label": "Lomami"
      },
      {
        "value": "LU",
        "label": "Lualaba"
      },
      {
        "value": "MA",
        "label": "Maniema"
      },
      {
        "value": "MN",
        "label": "Mai-Ndombe"
      },
      {
        "value": "MO",
        "label": "Mongala"
      },
      {
        "value": "NK",
        "label": "Nord-Kivu"
      },
      {
        "value": "NU",
        "label": "Nord-Ubangi"
      },
      {
        "value": "SA",
        "label": "Sankuru"
      },
      {
        "value": "SK",
        "label": "Sud-Kivu"
      },
      {
        "value": "SU",
        "label": "Sud-Ubangi"
      },
      {
        "value": "TA",
        "label": "Tanganyika"
      },
      {
        "value": "TO",
        "label": "Tshopo"
      },
      {
        "value": "TU",
        "label": "Tshuapa"
      }
    ]
  },
  {
    "value": "CF",
    "label": "Central African Republic",
    "states": [
      {
        "value": "AC",
        "label": "Ouham"
      },
      {
        "value": "BB",
        "label": "Bamingui-Bangoran"
      },
      {
        "value": "BGF",
        "label": "Bangui"
      },
      {
        "value": "BK",
        "label": "Basse-Kotto"
      },
      {
        "value": "HK",
        "label": "Haute-Kotto"
      },
      {
        "value": "HM",
        "label": "Haut-Mbomou"
      },
      {
        "value": "HS",
        "label": "Haute-Sangha / Mambéré-Kadéï"
      },
      {
        "value": "KB",
        "label": "Gribingui"
      },
      {
        "value": "KG",
        "label": "Kémo-Gribingui"
      },
      {
        "value": "LB",
        "label": "Lobaye"
      },
      {
        "value": "MB",
        "label": "Mbomou"
      },
      {
        "value": "MP",
        "label": "Ombella-Mpoko"
      },
      {
        "value": "NM",
        "label": "Nana-Mambéré"
      },
      {
        "value": "OP",
        "label": "Ouham-Pendé"
      },
      {
        "value": "SE",
        "label": "Sangha"
      },
      {
        "value": "UK",
        "label": "Ouaka"
      },
      {
        "value": "VK",
        "label": "Vakaga"
      }
    ]
  },
  {
    "value": "CG",
    "label": "Congo",
    "states": [
      {
        "value": "11",
        "label": "Bouenza"
      },
      {
        "value": "12",
        "label": "Pool"
      },
      {
        "value": "13",
        "label": "Sangha"
      },
      {
        "value": "14",
        "label": "Plateaux"
      },
      {
        "value": "15",
        "label": "Cuvette-Ouest"
      },
      {
        "value": "16",
        "label": "Pointe-Noire"
      },
      {
        "value": "2",
        "label": "Lékoumou"
      },
      {
        "value": "5",
        "label": "Kouilou"
      },
      {
        "value": "7",
        "label": "Likouala"
      },
      {
        "value": "8",
        "label": "Cuvette"
      },
      {
        "value": "9",
        "label": "Niari"
      },
      {
        "value": "BZV",
        "label": "Brazzaville"
      }
    ]
  },
  {
    "value": "CH",
    "label": "Switzerland",
    "states": [
      {
        "value": "AG",
        "label": "Aargau"
      },
      {
        "value": "AI",
        "label": "Appenzell Innerrhoden"
      },
      {
        "value": "AR",
        "label": "Appenzell Ausserrhoden"
      },
      {
        "value": "BE",
        "label": "Berne"
      },
      {
        "value": "BL",
        "label": "Basel-Landschaft"
      },
      {
        "value": "BS",
        "label": "Basel-Stadt"
      },
      {
        "value": "FR",
        "label": "Fribourg"
      },
      {
        "value": "GE",
        "label": "Genève"
      },
      {
        "value": "GL",
        "label": "Glarus"
      },
      {
        "value": "GR",
        "label": "Grischun"
      },
      {
        "value": "JU",
        "label": "Jura"
      },
      {
        "value": "LU",
        "label": "Luzern"
      },
      {
        "value": "NE",
        "label": "Neuchâtel"
      },
      {
        "value": "NW",
        "label": "Nidwalden"
      },
      {
        "value": "OW",
        "label": "Obwalden"
      },
      {
        "value": "SG",
        "label": "Sankt Gallen"
      },
      {
        "value": "SH",
        "label": "Schaffhausen"
      },
      {
        "value": "SO",
        "label": "Solothurn"
      },
      {
        "value": "SZ",
        "label": "Schwyz"
      },
      {
        "value": "TG",
        "label": "Thurgau"
      },
      {
        "value": "TI",
        "label": "Ticino"
      },
      {
        "value": "UR",
        "label": "Uri"
      },
      {
        "value": "VD",
        "label": "Vaud"
      },
      {
        "value": "VS",
        "label": "Valais"
      },
      {
        "value": "ZG",
        "label": "Zug"
      },
      {
        "value": "ZH",
        "label": "Zürich"
      }
    ]
  },
  {
    "value": "CI",
    "label": "Cote d'Ivoire",
    "states": [
      {
        "value": "AB",
        "label": "Abidjan"
      },
      {
        "value": "BS",
        "label": "Bas-Sassandra"
      },
      {
        "value": "CM",
        "label": "Comoé"
      },
      {
        "value": "DN",
        "label": "Denguélé"
      },
      {
        "value": "GD",
        "label": "Gôh-Djiboua"
      },
      {
        "value": "LC",
        "label": "Lacs"
      },
      {
        "value": "LG",
        "label": "Lagunes"
      },
      {
        "value": "MG",
        "label": "Montagnes"
      },
      {
        "value": "SM",
        "label": "Sassandra-Marahoué"
      },
      {
        "value": "SV",
        "label": "Savanes"
      },
      {
        "value": "VB",
        "label": "Vallée du Bandama"
      },
      {
        "value": "WR",
        "label": "Woroba"
      },
      {
        "value": "YM",
        "label": "Yamoussoukro"
      },
      {
        "value": "ZZ",
        "label": "Zanzan"
      }
    ]
  },
  {
    "value": "CK",
    "label": "Cook Islands",
    "states": []
  },
  {
    "value": "CL",
    "label": "Chile",
    "states": [
      {
        "value": "AI",
        "label": "Aysén, Aisén"
      },
      {
        "value": "AN",
        "label": "Antofagasta"
      },
      {
        "value": "AP",
        "label": "Arica y Parinacota"
      },
      {
        "value": "AR",
        "label": "La Araucanía"
      },
      {
        "value": "AT",
        "label": "Atacama"
      },
      {
        "value": "BI",
        "label": "Biobío"
      },
      {
        "value": "CO",
        "label": "Coquimbo"
      },
      {
        "value": "LI",
        "label": "O'Higgins"
      },
      {
        "value": "LL",
        "label": "Los Lagos"
      },
      {
        "value": "LR",
        "label": "Los Ríos"
      },
      {
        "value": "MA",
        "label": "Magallanes"
      },
      {
        "value": "ML",
        "label": "Maule"
      },
      {
        "value": "NB",
        "label": "Ñuble"
      },
      {
        "value": "RM",
        "label": "Región Metropolitana de Santiago"
      },
      {
        "value": "TA",
        "label": "Tarapacá"
      },
      {
        "value": "VS",
        "label": "Valparaíso"
      }
    ]
  },
  {
    "value": "CM",
    "label": "Cameroon",
    "states": [
      {
        "value": "AD",
        "label": "Adamaoua"
      },
      {
        "value": "CE",
        "label": "Centre"
      },
      {
        "value": "EN",
        "label": "Far North"
      },
      {
        "value": "ES",
        "label": "East"
      },
      {
        "value": "LT",
        "label": "Littoral"
      },
      {
        "value": "NO",
        "label": "North"
      },
      {
        "value": "NW",
        "label": "North-West"
      },
      {
        "value": "OU",
        "label": "West"
      },
      {
        "value": "SU",
        "label": "South"
      },
      {
        "value": "SW",
        "label": "South-West"
      }
    ]
  },
  {
    "value": "CN",
    "label": "China",
    "states": [
      {
        "value": "11",
        "label": "Beijing"
      },
      {
        "value": "12",
        "label": "Tianjin"
      },
      {
        "value": "13",
        "label": "Hebei"
      },
      {
        "value": "14",
        "label": "Shanxi"
      },
      {
        "value": "15",
        "label": "Nei Mongol"
      },
      {
        "value": "21",
        "label": "Liaoning"
      },
      {
        "value": "22",
        "label": "Jilin"
      },
      {
        "value": "23",
        "label": "Heilongjiang"
      },
      {
        "value": "31",
        "label": "Shanghai"
      },
      {
        "value": "32",
        "label": "Jiangsu"
      },
      {
        "value": "33",
        "label": "Zhejiang"
      },
      {
        "value": "34",
        "label": "Anhui"
      },
      {
        "value": "35",
        "label": "Fujian"
      },
      {
        "value": "36",
        "label": "Jiangxi"
      },
      {
        "value": "37",
        "label": "Shandong"
      },
      {
        "value": "41",
        "label": "Henan"
      },
      {
        "value": "42",
        "label": "Hubei"
      },
      {
        "value": "43",
        "label": "Hunan"
      },
      {
        "value": "44",
        "label": "Guangdong"
      },
      {
        "value": "45",
        "label": "Guangxi"
      },
      {
        "value": "46",
        "label": "Hainan"
      },
      {
        "value": "50",
        "label": "Chongqing"
      },
      {
        "value": "51",
        "label": "Sichuan"
      },
      {
        "value": "52",
        "label": "Guizhou"
      },
      {
        "value": "53",
        "label": "Yunnan"
      },
      {
        "value": "54",
        "label": "Xizang"
      },
      {
        "value": "61",
        "label": "Shaanxi"
      },
      {
        "value": "62",
        "label": "Gansu"
      },
      {
        "value": "63",
        "label": "Qinghai"
      },
      {
        "value": "64",
        "label": "Ningxia"
      },
      {
        "value": "65",
        "label": "Xinjiang"
      },
      {
        "value": "71",
        "label": "Chinese Taipei"
      },
      {
        "value": "91",
        "label": "Hong Kong"
      },
      {
        "value": "92",
        "label": "Macao"
      },
      {
        "value": "AH",
        "label": "Anhui Sheng"
      },
      {
        "value": "BJ",
        "label": "Beijing Shi"
      },
      {
        "value": "CQ",
        "label": "Chongqing Shi"
      },
      {
        "value": "FJ",
        "label": "Fujian Sheng"
      },
      {
        "value": "GD",
        "label": "Guangdong Sheng"
      },
      {
        "value": "GS",
        "label": "Gansu Sheng"
      },
      {
        "value": "GX",
        "label": "Guangxi Zhuangzu Zizhiqu"
      },
      {
        "value": "GZ",
        "label": "Guizhou Sheng"
      },
      {
        "value": "HA",
        "label": "Henan Sheng"
      },
      {
        "value": "HB",
        "label": "Hubei Sheng"
      },
      {
        "value": "HE",
        "label": "Hebei Sheng"
      },
      {
        "value": "HI",
        "label": "Hainan Sheng"
      },
      {
        "value": "HK",
        "label": "Hong Kong SAR"
      },
      {
        "value": "HL",
        "label": "Heilongjiang Sheng"
      },
      {
        "value": "HN",
        "label": "Hunan Sheng"
      },
      {
        "value": "JL",
        "label": "Jilin Sheng"
      },
      {
        "value": "JS",
        "label": "Jiangsu Sheng"
      },
      {
        "value": "JX",
        "label": "Jiangxi Sheng"
      },
      {
        "value": "LN",
        "label": "Liaoning Sheng"
      },
      {
        "value": "MO",
        "label": "Macao SAR"
      },
      {
        "value": "NM",
        "label": "Nei Mongol Zizhiqu"
      },
      {
        "value": "NX",
        "label": "Ningxia Huizu Zizhiqu"
      },
      {
        "value": "QH",
        "label": "Qinghai Sheng"
      },
      {
        "value": "SC",
        "label": "Sichuan Sheng"
      },
      {
        "value": "SD",
        "label": "Shandong Sheng"
      },
      {
        "value": "SH",
        "label": "Shanghai Shi"
      },
      {
        "value": "SN",
        "label": "Shaanxi Sheng"
      },
      {
        "value": "SX",
        "label": "Shanxi Sheng"
      },
      {
        "value": "TJ",
        "label": "Tianjin Shi"
      },
      {
        "value": "TW",
        "label": "Taiwan Sheng"
      },
      {
        "value": "XJ",
        "label": "Xinjiang Uygur Zizhiqu"
      },
      {
        "value": "XZ",
        "label": "Xizang Zizhiqu"
      },
      {
        "value": "YN",
        "label": "Yunnan Sheng"
      },
      {
        "value": "ZJ",
        "label": "Zhejiang Sheng"
      }
    ]
  },
  {
    "value": "CO",
    "label": "Colombia",
    "states": [
      {
        "value": "AMA",
        "label": "Amazonas"
      },
      {
        "value": "ANT",
        "label": "Antioquia"
      },
      {
        "value": "ARA",
        "label": "Arauca"
      },
      {
        "value": "ATL",
        "label": "Atlántico"
      },
      {
        "value": "BOL",
        "label": "Bolívar"
      },
      {
        "value": "BOY",
        "label": "Boyacá"
      },
      {
        "value": "CAL",
        "label": "Caldas"
      },
      {
        "value": "CAQ",
        "label": "Caquetá"
      },
      {
        "value": "CAS",
        "label": "Casanare"
      },
      {
        "value": "CAU",
        "label": "Cauca"
      },
      {
        "value": "CES",
        "label": "Cesar"
      },
      {
        "value": "CHO",
        "label": "Chocó"
      },
      {
        "value": "COR",
        "label": "Córdoba"
      },
      {
        "value": "CUN",
        "label": "Cundinamarca"
      },
      {
        "value": "DC",
        "label": "Distrito Capital"
      },
      {
        "value": "GUA",
        "label": "Guainía"
      },
      {
        "value": "GUV",
        "label": "Guaviare"
      },
      {
        "value": "HUI",
        "label": "Huila"
      },
      {
        "value": "LAG",
        "label": "La Guajira"
      },
      {
        "value": "MAG",
        "label": "Magdalena"
      },
      {
        "value": "MET",
        "label": "Meta"
      },
      {
        "value": "NAR",
        "label": "Nariño"
      },
      {
        "value": "NSA",
        "label": "Norte de Santander"
      },
      {
        "value": "PUT",
        "label": "Putumayo"
      },
      {
        "value": "QUI",
        "label": "Quindío"
      },
      {
        "value": "RIS",
        "label": "Risaralda"
      },
      {
        "value": "SAN",
        "label": "Santander"
      },
      {
        "value": "SAP",
        "label": "San Andrés"
      },
      {
        "value": "SUC",
        "label": "Sucre"
      },
      {
        "value": "TOL",
        "label": "Tolima"
      },
      {
        "value": "VAC",
        "label": "Valle"
      },
      {
        "value": "VAU",
        "label": "Vaupés"
      },
      {
        "value": "VID",
        "label": "Vichada"
      }
    ]
  },
  {
    "value": "CR",
    "label": "Costa Rica",
    "states": [
      {
        "value": "A",
        "label": "Alajuela"
      },
      {
        "value": "C",
        "label": "Cartago"
      },
      {
        "value": "G",
        "label": "Guanacaste"
      },
      {
        "value": "H",
        "label": "Heredia"
      },
      {
        "value": "L",
        "label": "Limón"
      },
      {
        "value": "P",
        "label": "Puntarenas"
      },
      {
        "value": "SJ",
        "label": "San José"
      }
    ]
  },
  {
    "value": "CU",
    "label": "Cuba",
    "states": [
      {
        "value": "01",
        "label": "Pinar del Río"
      },
      {
        "value": "03",
        "label": "La Habana"
      },
      {
        "value": "04",
        "label": "Matanzas"
      },
      {
        "value": "05",
        "label": "Villa Clara"
      },
      {
        "value": "06",
        "label": "Cienfuegos"
      },
      {
        "value": "07",
        "label": "Sancti Spíritus"
      },
      {
        "value": "08",
        "label": "Ciego de Ávila"
      },
      {
        "value": "09",
        "label": "Camagüey"
      },
      {
        "value": "10",
        "label": "Las Tunas"
      },
      {
        "value": "11",
        "label": "Holguín"
      },
      {
        "value": "12",
        "label": "Granma"
      },
      {
        "value": "13",
        "label": "Santiago de Cuba"
      },
      {
        "value": "14",
        "label": "Guantánamo"
      },
      {
        "value": "15",
        "label": "Artemisa"
      },
      {
        "value": "16",
        "label": "Mayabeque"
      },
      {
        "value": "99",
        "label": "Isla de la Juventud"
      }
    ]
  },
  {
    "value": "CV",
    "label": "Cape Verde",
    "states": [
      {
        "value": "B",
        "label": "Ilhas de Barlavento"
      },
      {
        "value": "BR",
        "label": "Brava"
      },
      {
        "value": "BV",
        "label": "Boa Vista"
      },
      {
        "value": "CA",
        "label": "Santa Catarina"
      },
      {
        "value": "CF",
        "label": "Santa Catarina do Fogo"
      },
      {
        "value": "CR",
        "label": "Santa Cruz"
      },
      {
        "value": "MA",
        "label": "Maio"
      },
      {
        "value": "MO",
        "label": "Mosteiros"
      },
      {
        "value": "PA",
        "label": "Paul"
      },
      {
        "value": "PN",
        "label": "Porto Novo"
      },
      {
        "value": "PR",
        "label": "Praia"
      },
      {
        "value": "RB",
        "label": "Ribeira Brava"
      },
      {
        "value": "RG",
        "label": "Ribeira Grande"
      },
      {
        "value": "RS",
        "label": "Ribeira Grande de Santiago"
      },
      {
        "value": "S",
        "label": "Ilhas de Sotavento"
      },
      {
        "value": "SD",
        "label": "São Domingos"
      },
      {
        "value": "SF",
        "label": "São Filipe"
      },
      {
        "value": "SL",
        "label": "Sal"
      },
      {
        "value": "SM",
        "label": "São Miguel"
      },
      {
        "value": "SO",
        "label": "São Lourenço dos Órgãos"
      },
      {
        "value": "SS",
        "label": "São Salvador do Mundo"
      },
      {
        "value": "SV",
        "label": "São Vicente"
      },
      {
        "value": "TA",
        "label": "Tarrafal"
      },
      {
        "value": "TS",
        "label": "Tarrafal de São Nicolau"
      }
    ]
  },
  {
    "value": "CW",
    "label": "Curaçao",
    "states": []
  },
  {
    "value": "CX",
    "label": "Christmas Island",
    "states": []
  },
  {
    "value": "CY",
    "label": "Cyprus",
    "states": [
      {
        "value": "01",
        "label": "Lefkosia"
      },
      {
        "value": "02",
        "label": "Lemesos"
      },
      {
        "value": "03",
        "label": "Larnaka"
      },
      {
        "value": "04",
        "label": "Ammochostos"
      },
      {
        "value": "05",
        "label": "Pafos"
      },
      {
        "value": "06",
        "label": "Keryneia"
      }
    ]
  },
  {
    "value": "CZ",
    "label": "Czech Republic",
    "states": [
      {
        "value": "10",
        "label": "Praha, Hlavní město"
      },
      {
        "value": "20",
        "label": "Středočeský kraj"
      },
      {
        "value": "201",
        "label": "Benešov"
      },
      {
        "value": "202",
        "label": "Beroun"
      },
      {
        "value": "203",
        "label": "Kladno"
      },
      {
        "value": "204",
        "label": "Kolín"
      },
      {
        "value": "205",
        "label": "Kutná Hora"
      },
      {
        "value": "206",
        "label": "Mělník"
      },
      {
        "value": "207",
        "label": "Mladá Boleslav"
      },
      {
        "value": "208",
        "label": "Nymburk"
      },
      {
        "value": "209",
        "label": "Praha-východ"
      },
      {
        "value": "20A",
        "label": "Praha-západ"
      },
      {
        "value": "20B",
        "label": "Příbram"
      },
      {
        "value": "20C",
        "label": "Rakovník"
      },
      {
        "value": "31",
        "label": "Jihočeský kraj"
      },
      {
        "value": "311",
        "label": "České Budějovice"
      },
      {
        "value": "312",
        "label": "Český Krumlov"
      },
      {
        "value": "313",
        "label": "Jindřichův Hradec"
      },
      {
        "value": "314",
        "label": "Písek"
      },
      {
        "value": "315",
        "label": "Prachatice"
      },
      {
        "value": "316",
        "label": "Strakonice"
      },
      {
        "value": "317",
        "label": "Tábor"
      },
      {
        "value": "32",
        "label": "Plzeňský kraj"
      },
      {
        "value": "321",
        "label": "Domažlice"
      },
      {
        "value": "322",
        "label": "Klatovy"
      },
      {
        "value": "323",
        "label": "Plzeň-město"
      },
      {
        "value": "324",
        "label": "Plzeň-jih"
      },
      {
        "value": "325",
        "label": "Plzeň-sever"
      },
      {
        "value": "326",
        "label": "Rokycany"
      },
      {
        "value": "327",
        "label": "Tachov"
      },
      {
        "value": "41",
        "label": "Karlovarský kraj"
      },
      {
        "value": "411",
        "label": "Cheb"
      },
      {
        "value": "412",
        "label": "Karlovy Vary"
      },
      {
        "value": "413",
        "label": "Sokolov"
      },
      {
        "value": "42",
        "label": "Ústecký kraj"
      },
      {
        "value": "421",
        "label": "Děčín"
      },
      {
        "value": "422",
        "label": "Chomutov"
      },
      {
        "value": "423",
        "label": "Litoměřice"
      },
      {
        "value": "424",
        "label": "Louny"
      },
      {
        "value": "425",
        "label": "Most"
      },
      {
        "value": "426",
        "label": "Teplice"
      },
      {
        "value": "427",
        "label": "Ústí nad Labem"
      },
      {
        "value": "51",
        "label": "Liberecký kraj"
      },
      {
        "value": "511",
        "label": "Česká Lípa"
      },
      {
        "value": "512",
        "label": "Jablonec nad Nisou"
      },
      {
        "value": "513",
        "label": "Liberec"
      },
      {
        "value": "514",
        "label": "Semily"
      },
      {
        "value": "52",
        "label": "Královéhradecký kraj"
      },
      {
        "value": "521",
        "label": "Hradec Králové"
      },
      {
        "value": "522",
        "label": "Jičín"
      },
      {
        "value": "523",
        "label": "Náchod"
      },
      {
        "value": "524",
        "label": "Rychnov nad Kněžnou"
      },
      {
        "value": "525",
        "label": "Trutnov"
      },
      {
        "value": "53",
        "label": "Pardubický kraj"
      },
      {
        "value": "531",
        "label": "Chrudim"
      },
      {
        "value": "532",
        "label": "Pardubice"
      },
      {
        "value": "533",
        "label": "Svitavy"
      },
      {
        "value": "534",
        "label": "Ústí nad Orlicí"
      },
      {
        "value": "63",
        "label": "Kraj Vysočina"
      },
      {
        "value": "631",
        "label": "Havlíčkův Brod"
      },
      {
        "value": "632",
        "label": "Jihlava"
      },
      {
        "value": "633",
        "label": "Pelhřimov"
      },
      {
        "value": "634",
        "label": "Třebíč"
      },
      {
        "value": "635",
        "label": "Žďár nad Sázavou"
      },
      {
        "value": "64",
        "label": "Jihomoravský kraj"
      },
      {
        "value": "641",
        "label": "Blansko"
      },
      {
        "value": "642",
        "label": "Brno-město"
      },
      {
        "value": "643",
        "label": "Brno-venkov"
      },
      {
        "value": "644",
        "label": "Břeclav"
      },
      {
        "value": "645",
        "label": "Hodonín"
      },
      {
        "value": "646",
        "label": "Vyškov"
      },
      {
        "value": "647",
        "label": "Znojmo"
      },
      {
        "value": "71",
        "label": "Olomoucký kraj"
      },
      {
        "value": "711",
        "label": "Jeseník"
      },
      {
        "value": "712",
        "label": "Olomouc"
      },
      {
        "value": "713",
        "label": "Prostějov"
      },
      {
        "value": "714",
        "label": "Přerov"
      },
      {
        "value": "715",
        "label": "Šumperk"
      },
      {
        "value": "72",
        "label": "Zlínský kraj"
      },
      {
        "value": "721",
        "label": "Kroměříž"
      },
      {
        "value": "722",
        "label": "Uherské Hradiště"
      },
      {
        "value": "723",
        "label": "Vsetín"
      },
      {
        "value": "724",
        "label": "Zlín"
      },
      {
        "value": "80",
        "label": "Moravskoslezský kraj"
      },
      {
        "value": "801",
        "label": "Bruntál"
      },
      {
        "value": "802",
        "label": "Frýdek-Místek"
      },
      {
        "value": "803",
        "label": "Karviná"
      },
      {
        "value": "804",
        "label": "Nový Jičín"
      },
      {
        "value": "805",
        "label": "Opava"
      },
      {
        "value": "806",
        "label": "Ostrava-město"
      }
    ]
  },
  {
    "value": "DE",
    "label": "Germany",
    "states": [
      {
        "value": "BB",
        "label": "Brandenburg"
      },
      {
        "value": "BE",
        "label": "Berlin"
      },
      {
        "value": "BW",
        "label": "Baden-Württemberg"
      },
      {
        "value": "BY",
        "label": "Bayern"
      },
      {
        "value": "HB",
        "label": "Bremen"
      },
      {
        "value": "HE",
        "label": "Hessen"
      },
      {
        "value": "HH",
        "label": "Hamburg"
      },
      {
        "value": "MV",
        "label": "Mecklenburg-Vorpommern"
      },
      {
        "value": "NI",
        "label": "Niedersachsen"
      },
      {
        "value": "NW",
        "label": "Nordrhein-Westfalen"
      },
      {
        "value": "RP",
        "label": "Rheinland-Pfalz"
      },
      {
        "value": "SH",
        "label": "Schleswig-Holstein"
      },
      {
        "value": "SL",
        "label": "Saarland"
      },
      {
        "value": "SN",
        "label": "Sachsen"
      },
      {
        "value": "ST",
        "label": "Sachsen-Anhalt"
      },
      {
        "value": "TH",
        "label": "Thüringen"
      }
    ]
  },
  {
    "value": "DJ",
    "label": "Djibouti",
    "states": [
      {
        "value": "AR",
        "label": "Arta"
      },
      {
        "value": "AS",
        "label": "Ali Sabieh"
      },
      {
        "value": "DI",
        "label": "Dikhil"
      },
      {
        "value": "DJ",
        "label": "Djibouti"
      },
      {
        "value": "OB",
        "label": "Obock"
      },
      {
        "value": "TA",
        "label": "Tadjourah"
      }
    ]
  },
  {
    "value": "DK",
    "label": "Denmark",
    "states": [
      {
        "value": "81",
        "label": "Nordjylland"
      },
      {
        "value": "82",
        "label": "Midtjylland"
      },
      {
        "value": "83",
        "label": "Syddanmark"
      },
      {
        "value": "84",
        "label": "Hovedstaden"
      },
      {
        "value": "85",
        "label": "Sjælland"
      }
    ]
  },
  {
    "value": "DM",
    "label": "Dominica",
    "states": [
      {
        "value": "02",
        "label": "Saint Andrew"
      },
      {
        "value": "03",
        "label": "Saint David"
      },
      {
        "value": "04",
        "label": "Saint George"
      },
      {
        "value": "05",
        "label": "Saint John"
      },
      {
        "value": "06",
        "label": "Saint Joseph"
      },
      {
        "value": "07",
        "label": "Saint Luke"
      },
      {
        "value": "08",
        "label": "Saint Mark"
      },
      {
        "value": "09",
        "label": "Saint Patrick"
      },
      {
        "value": "10",
        "label": "Saint Paul"
      },
      {
        "value": "11",
        "label": "Saint Peter"
      }
    ]
  },
  {
    "value": "DO",
    "label": "Dominican Republic",
    "states": [
      {
        "value": "01",
        "label": "Distrito Nacional (Santo Domingo)"
      },
      {
        "value": "02",
        "label": "Azua"
      },
      {
        "value": "03",
        "label": "Baoruco"
      },
      {
        "value": "04",
        "label": "Barahona"
      },
      {
        "value": "05",
        "label": "Dajabón"
      },
      {
        "value": "06",
        "label": "Duarte"
      },
      {
        "value": "07",
        "label": "Elías Piña"
      },
      {
        "value": "08",
        "label": "El Seibo"
      },
      {
        "value": "09",
        "label": "Espaillat"
      },
      {
        "value": "10",
        "label": "Independencia"
      },
      {
        "value": "11",
        "label": "La Altagracia"
      },
      {
        "value": "12",
        "label": "La Romana"
      },
      {
        "value": "13",
        "label": "La Vega"
      },
      {
        "value": "14",
        "label": "María Trinidad Sánchez"
      },
      {
        "value": "15",
        "label": "Monte Cristi"
      },
      {
        "value": "16",
        "label": "Pedernales"
      },
      {
        "value": "17",
        "label": "Peravia"
      },
      {
        "value": "18",
        "label": "Puerto Plata"
      },
      {
        "value": "19",
        "label": "Hermanas Mirabal"
      },
      {
        "value": "20",
        "label": "Samaná"
      },
      {
        "value": "21",
        "label": "San Cristóbal"
      },
      {
        "value": "22",
        "label": "San Juan"
      },
      {
        "value": "23",
        "label": "San Pedro de Macorís"
      },
      {
        "value": "24",
        "label": "Sánchez Ramírez"
      },
      {
        "value": "25",
        "label": "Santiago"
      },
      {
        "value": "26",
        "label": "Santiago Rodríguez"
      },
      {
        "value": "27",
        "label": "Valverde"
      },
      {
        "value": "28",
        "label": "Monseñor Nouel"
      },
      {
        "value": "29",
        "label": "Monte Plata"
      },
      {
        "value": "30",
        "label": "Hato Mayor"
      },
      {
        "value": "31",
        "label": "San José de Ocoa"
      },
      {
        "value": "32",
        "label": "Santo Domingo"
      },
      {
        "value": "33",
        "label": "Cibao Nordeste"
      },
      {
        "value": "34",
        "label": "Cibao Noroeste"
      },
      {
        "value": "35",
        "label": "Cibao Norte"
      },
      {
        "value": "36",
        "label": "Cibao Sur"
      },
      {
        "value": "37",
        "label": "El Valle"
      },
      {
        "value": "38",
        "label": "Enriquillo"
      },
      {
        "value": "39",
        "label": "Higuamo"
      },
      {
        "value": "40",
        "label": "Ozama"
      },
      {
        "value": "41",
        "label": "Valdesia"
      },
      {
        "value": "42",
        "label": "Yuma"
      }
    ]
  },
  {
    "value": "DZ",
    "label": "Algeria",
    "states": [
      {
        "value": "01",
        "label": "Adrar"
      },
      {
        "value": "02",
        "label": "Chlef"
      },
      {
        "value": "03",
        "label": "Laghouat"
      },
      {
        "value": "04",
        "label": "Oum el Bouaghi"
      },
      {
        "value": "05",
        "label": "Batna"
      },
      {
        "value": "06",
        "label": "Béjaïa"
      },
      {
        "value": "07",
        "label": "Biskra"
      },
      {
        "value": "08",
        "label": "Béchar"
      },
      {
        "value": "09",
        "label": "Blida"
      },
      {
        "value": "10",
        "label": "Bouira"
      },
      {
        "value": "11",
        "label": "Tamanrasset"
      },
      {
        "value": "12",
        "label": "Tébessa"
      },
      {
        "value": "13",
        "label": "Tlemcen"
      },
      {
        "value": "14",
        "label": "Tiaret"
      },
      {
        "value": "15",
        "label": "Tizi Ouzou"
      },
      {
        "value": "16",
        "label": "Alger"
      },
      {
        "value": "17",
        "label": "Djelfa"
      },
      {
        "value": "18",
        "label": "Jijel"
      },
      {
        "value": "19",
        "label": "Sétif"
      },
      {
        "value": "20",
        "label": "Saïda"
      },
      {
        "value": "21",
        "label": "Skikda"
      },
      {
        "value": "22",
        "label": "Sidi Bel Abbès"
      },
      {
        "value": "23",
        "label": "Annaba"
      },
      {
        "value": "24",
        "label": "Guelma"
      },
      {
        "value": "25",
        "label": "Constantine"
      },
      {
        "value": "26",
        "label": "Médéa"
      },
      {
        "value": "27",
        "label": "Mostaganem"
      },
      {
        "value": "28",
        "label": "M'sila"
      },
      {
        "value": "29",
        "label": "Mascara"
      },
      {
        "value": "30",
        "label": "Ouargla"
      },
      {
        "value": "31",
        "label": "Oran"
      },
      {
        "value": "32",
        "label": "El Bayadh"
      },
      {
        "value": "33",
        "label": "Illizi"
      },
      {
        "value": "34",
        "label": "Bordj Bou Arréridj"
      },
      {
        "value": "35",
        "label": "Boumerdès"
      },
      {
        "value": "36",
        "label": "El Tarf"
      },
      {
        "value": "37",
        "label": "Tindouf"
      },
      {
        "value": "38",
        "label": "Tissemsilt"
      },
      {
        "value": "39",
        "label": "El Oued"
      },
      {
        "value": "40",
        "label": "Khenchela"
      },
      {
        "value": "41",
        "label": "Souk Ahras"
      },
      {
        "value": "42",
        "label": "Tipaza"
      },
      {
        "value": "43",
        "label": "Mila"
      },
      {
        "value": "44",
        "label": "Aïn Defla"
      },
      {
        "value": "45",
        "label": "Naama"
      },
      {
        "value": "46",
        "label": "Aïn Témouchent"
      },
      {
        "value": "47",
        "label": "Ghardaïa"
      },
      {
        "value": "48",
        "label": "Relizane"
      },
      {
        "value": "49",
        "label": "Timimoun"
      },
      {
        "value": "50",
        "label": "Bordj Badji Mokhtar"
      },
      {
        "value": "51",
        "label": "Ouled Djellal"
      },
      {
        "value": "52",
        "label": "Béni Abbès"
      },
      {
        "value": "53",
        "label": "In Salah"
      },
      {
        "value": "54",
        "label": "In Guezzam"
      },
      {
        "value": "55",
        "label": "Touggourt"
      },
      {
        "value": "56",
        "label": "Djanet"
      },
      {
        "value": "57",
        "label": "El Meghaier"
      },
      {
        "value": "58",
        "label": "El Meniaa"
      }
    ]
  },
  {
    "value": "EC",
    "label": "Ecuador",
    "states": [
      {
        "value": "A",
        "label": "Azuay"
      },
      {
        "value": "B",
        "label": "Bolívar"
      },
      {
        "value": "C",
        "label": "Carchi"
      },
      {
        "value": "D",
        "label": "Orellana"
      },
      {
        "value": "E",
        "label": "Esmeraldas"
      },
      {
        "value": "F",
        "label": "Cañar"
      },
      {
        "value": "G",
        "label": "Guayas"
      },
      {
        "value": "H",
        "label": "Chimborazo"
      },
      {
        "value": "I",
        "label": "Imbabura"
      },
      {
        "value": "L",
        "label": "Loja"
      },
      {
        "value": "M",
        "label": "Manabí"
      },
      {
        "value": "N",
        "label": "Napo"
      },
      {
        "value": "O",
        "label": "El Oro"
      },
      {
        "value": "P",
        "label": "Pichincha"
      },
      {
        "value": "R",
        "label": "Los Ríos"
      },
      {
        "value": "S",
        "label": "Morona Santiago"
      },
      {
        "value": "SD",
        "label": "Santo Domingo de los Tsáchilas"
      },
      {
        "value": "SE",
        "label": "Santa Elena"
      },
      {
        "value": "T",
        "label": "Tungurahua"
      },
      {
        "value": "U",
        "label": "Sucumbíos"
      },
      {
        "value": "W",
        "label": "Galápagos"
      },
      {
        "value": "X",
        "label": "Cotopaxi"
      },
      {
        "value": "Y",
        "label": "Pastaza"
      },
      {
        "value": "Z",
        "label": "Zamora Chinchipe"
      }
    ]
  },
  {
    "value": "EE",
    "label": "Estonia",
    "states": [
      {
        "value": "130",
        "label": "Alutaguse"
      },
      {
        "value": "141",
        "label": "Anija"
      },
      {
        "value": "142",
        "label": "Antsla"
      },
      {
        "value": "171",
        "label": "Elva"
      },
      {
        "value": "184",
        "label": "Haapsalu"
      },
      {
        "value": "191",
        "label": "Haljala"
      },
      {
        "value": "198",
        "label": "Harku"
      },
      {
        "value": "214",
        "label": "Häädemeeste"
      },
      {
        "value": "245",
        "label": "Jõelähtme"
      },
      {
        "value": "247",
        "label": "Jõgeva"
      },
      {
        "value": "251",
        "label": "Jõhvi"
      },
      {
        "value": "255",
        "label": "Järva"
      },
      {
        "value": "272",
        "label": "Kadrina"
      },
      {
        "value": "283",
        "label": "Kambja"
      },
      {
        "value": "284",
        "label": "Kanepi"
      },
      {
        "value": "291",
        "label": "Kastre"
      },
      {
        "value": "293",
        "label": "Kehtna"
      },
      {
        "value": "296",
        "label": "Keila"
      },
      {
        "value": "303",
        "label": "Kihnu"
      },
      {
        "value": "305",
        "label": "Kiili"
      },
      {
        "value": "317",
        "label": "Kohila"
      },
      {
        "value": "321",
        "label": "Kohtla-Järve"
      },
      {
        "value": "338",
        "label": "Kose"
      },
      {
        "value": "353",
        "label": "Kuusalu"
      },
      {
        "value": "37",
        "label": "Harjumaa"
      },
      {
        "value": "39",
        "label": "Hiiumaa"
      },
      {
        "value": "424",
        "label": "Loksa"
      },
      {
        "value": "430",
        "label": "Lääneranna"
      },
      {
        "value": "431",
        "label": "Lääne-Harju"
      },
      {
        "value": "432",
        "label": "Luunja"
      },
      {
        "value": "441",
        "label": "Lääne-Nigula"
      },
      {
        "value": "442",
        "label": "Lüganuse"
      },
      {
        "value": "446",
        "label": "Maardu"
      },
      {
        "value": "45",
        "label": "Ida-Virumaa"
      },
      {
        "value": "478",
        "label": "Muhu"
      },
      {
        "value": "480",
        "label": "Mulgi"
      },
      {
        "value": "486",
        "label": "Mustvee"
      },
      {
        "value": "50",
        "label": "Jõgevamaa"
      },
      {
        "value": "503",
        "label": "Märjamaa"
      },
      {
        "value": "511",
        "label": "Narva"
      },
      {
        "value": "514",
        "label": "Narva-Jõesuu"
      },
      {
        "value": "52",
        "label": "Järvamaa"
      },
      {
        "value": "528",
        "label": "Nõo"
      },
      {
        "value": "557",
        "label": "Otepää"
      },
      {
        "value": "56",
        "label": "Läänemaa"
      },
      {
        "value": "567",
        "label": "Paide"
      },
      {
        "value": "586",
        "label": "Peipsiääre"
      },
      {
        "value": "60",
        "label": "Lääne-Virumaa"
      },
      {
        "value": "615",
        "label": "Põhja-Sakala"
      },
      {
        "value": "618",
        "label": "Põltsamaa"
      },
      {
        "value": "622",
        "label": "Põlva"
      },
      {
        "value": "624",
        "label": "Pärnu"
      },
      {
        "value": "638",
        "label": "Põhja-Pärnumaa"
      },
      {
        "value": "64",
        "label": "Põlvamaa"
      },
      {
        "value": "651",
        "label": "Raasiku"
      },
      {
        "value": "653",
        "label": "Rae"
      },
      {
        "value": "663",
        "label": "Rakvere"
      },
      {
        "value": "668",
        "label": "Rapla"
      },
      {
        "value": "68",
        "label": "Pärnumaa"
      },
      {
        "value": "689",
        "label": "Ruhnu"
      },
      {
        "value": "698",
        "label": "Rõuge"
      },
      {
        "value": "708",
        "label": "Räpina"
      },
      {
        "value": "71",
        "label": "Raplamaa"
      },
      {
        "value": "712",
        "label": "Saarde"
      },
      {
        "value": "719",
        "label": "Saku"
      },
      {
        "value": "726",
        "label": "Saue"
      },
      {
        "value": "732",
        "label": "Setomaa"
      },
      {
        "value": "735",
        "label": "Sillamäe"
      },
      {
        "value": "74",
        "label": "Saaremaa"
      },
      {
        "value": "784",
        "label": "Tallinn"
      },
      {
        "value": "79",
        "label": "Tartumaa"
      },
      {
        "value": "792",
        "label": "Tapa"
      },
      {
        "value": "796",
        "label": "Tartu"
      },
      {
        "value": "803",
        "label": "Toila"
      },
      {
        "value": "809",
        "label": "Tori"
      },
      {
        "value": "81",
        "label": "Valgamaa"
      },
      {
        "value": "824",
        "label": "Tõrva"
      },
      {
        "value": "834",
        "label": "Türi"
      },
      {
        "value": "84",
        "label": "Viljandimaa"
      },
      {
        "value": "855",
        "label": "Valga"
      },
      {
        "value": "87",
        "label": "Võrumaa"
      },
      {
        "value": "890",
        "label": "Viimsi"
      },
      {
        "value": "899",
        "label": "Viljandi"
      },
      {
        "value": "901",
        "label": "Vinni"
      },
      {
        "value": "903",
        "label": "Viru-Nigula"
      },
      {
        "value": "907",
        "label": "Vormsi"
      },
      {
        "value": "919",
        "label": "Võru"
      },
      {
        "value": "928",
        "label": "Väike-Maarja"
      }
    ]
  },
  {
    "value": "EG",
    "label": "Egypt",
    "states": [
      {
        "value": "ALX",
        "label": "Alexandria"
      },
      {
        "value": "ASN",
        "label": "Aswān"
      },
      {
        "value": "AST",
        "label": "Asyūţ"
      },
      {
        "value": "BA",
        "label": "Red Sea"
      },
      {
        "value": "BH",
        "label": "Al Buḩayrah"
      },
      {
        "value": "BNS",
        "label": "Banī Suwayf"
      },
      {
        "value": "C",
        "label": "Cairo"
      },
      {
        "value": "DK",
        "label": "Ad Daqahlīyah"
      },
      {
        "value": "DT",
        "label": "Damietta"
      },
      {
        "value": "FYM",
        "label": "Al Fayyūm"
      },
      {
        "value": "GH",
        "label": "Al Gharbīyah"
      },
      {
        "value": "GZ",
        "label": "Giza"
      },
      {
        "value": "IS",
        "label": "Al Ismā'īlīyah"
      },
      {
        "value": "JS",
        "label": "South Sinai"
      },
      {
        "value": "KB",
        "label": "Al Qalyūbīyah"
      },
      {
        "value": "KFS",
        "label": "Kafr ash Shaykh"
      },
      {
        "value": "KN",
        "label": "Qinā"
      },
      {
        "value": "LX",
        "label": "Luxor"
      },
      {
        "value": "MN",
        "label": "Al Minyā"
      },
      {
        "value": "MNF",
        "label": "Al Minūfīyah"
      },
      {
        "value": "MT",
        "label": "Maţrūḩ"
      },
      {
        "value": "PTS",
        "label": "Port Said"
      },
      {
        "value": "SHG",
        "label": "Sohag"
      },
      {
        "value": "SHR",
        "label": "Ash Sharqīyah"
      },
      {
        "value": "SIN",
        "label": "North Sinai"
      },
      {
        "value": "SUZ",
        "label": "Suez"
      },
      {
        "value": "WAD",
        "label": "New Valley"
      }
    ]
  },
  {
    "value": "EH",
    "label": "Western Sahara",
    "states": []
  },
  {
    "value": "ER",
    "label": "Eritrea",
    "states": [
      {
        "value": "AN",
        "label": "Ansabā"
      },
      {
        "value": "DK",
        "label": "Janūbī al Baḩrī al Aḩmar"
      },
      {
        "value": "DU",
        "label": "Al Janūbī"
      },
      {
        "value": "GB",
        "label": "Qāsh-Barkah"
      },
      {
        "value": "MA",
        "label": "Al Awsaţ"
      },
      {
        "value": "SK",
        "label": "Shimālī al Baḩrī al Aḩmar"
      }
    ]
  },
  {
    "value": "ES",
    "label": "Spain",
    "states": [
      {
        "value": "35",
        "label": "Las Palmas"
      },
      {
        "value": "A",
        "label": "Alicante"
      },
      {
        "value": "AB",
        "label": "Albacete"
      },
      {
        "value": "AL",
        "label": "Almería"
      },
      {
        "value": "AN",
        "label": "Andalucía"
      },
      {
        "value": "AR",
        "label": "Aragón"
      },
      {
        "value": "AS",
        "label": "Asturias, Principado de"
      },
      {
        "value": "AV",
        "label": "Ávila"
      },
      {
        "value": "B",
        "label": "Barcelona"
      },
      {
        "value": "BA",
        "label": "Badajoz"
      },
      {
        "value": "BI",
        "label": "Bizkaia"
      },
      {
        "value": "BU",
        "label": "Burgos"
      },
      {
        "value": "C",
        "label": "A Coruña"
      },
      {
        "value": "CA",
        "label": "Cádiz"
      },
      {
        "value": "CC",
        "label": "Cáceres"
      },
      {
        "value": "CE",
        "label": "Ceuta"
      },
      {
        "value": "CL",
        "label": "Castilla y León"
      },
      {
        "value": "CM",
        "label": "Castilla-La Mancha"
      },
      {
        "value": "CN",
        "label": "Canarias"
      },
      {
        "value": "CO",
        "label": "Córdoba"
      },
      {
        "value": "CR",
        "label": "Ciudad Real"
      },
      {
        "value": "CS",
        "label": "Castellón"
      },
      {
        "value": "CT",
        "label": "Catalunya"
      },
      {
        "value": "CU",
        "label": "Cuenca"
      },
      {
        "value": "EX",
        "label": "Extremadura"
      },
      {
        "value": "GA",
        "label": "Galicia"
      },
      {
        "value": "GC",
        "label": "Las Palmas"
      },
      {
        "value": "GI",
        "label": "Girona"
      },
      {
        "value": "GR",
        "label": "Granada"
      },
      {
        "value": "GU",
        "label": "Guadalajara"
      },
      {
        "value": "H",
        "label": "Huelva"
      },
      {
        "value": "HU",
        "label": "Huesca"
      },
      {
        "value": "J",
        "label": "Jaén"
      },
      {
        "value": "L",
        "label": "Lleida"
      },
      {
        "value": "LE",
        "label": "León"
      },
      {
        "value": "LU",
        "label": "Lugo"
      },
      {
        "value": "M",
        "label": "Madrid"
      },
      {
        "value": "MA",
        "label": "Málaga"
      },
      {
        "value": "MC",
        "label": "Murcia, Región de"
      },
      {
        "value": "MD",
        "label": "Madrid, Comunidad de"
      },
      {
        "value": "ML",
        "label": "Melilla"
      },
      {
        "value": "MU",
        "label": "Murcia"
      },
      {
        "value": "NA",
        "label": "Navarra"
      },
      {
        "value": "NC",
        "label": "Navarra, Comunidad Foral de"
      },
      {
        "value": "O",
        "label": "Asturias"
      },
      {
        "value": "OR",
        "label": "Ourense"
      },
      {
        "value": "P",
        "label": "Palencia"
      },
      {
        "value": "PM",
        "label": "Illes Balears"
      },
      {
        "value": "PO",
        "label": "Pontevedra"
      },
      {
        "value": "PV",
        "label": "País Vasco"
      },
      {
        "value": "RI",
        "label": "La Rioja"
      },
      {
        "value": "S",
        "label": "Cantabria"
      },
      {
        "value": "SA",
        "label": "Salamanca"
      },
      {
        "value": "SE",
        "label": "Sevilla"
      },
      {
        "value": "SG",
        "label": "Segovia"
      },
      {
        "value": "SO",
        "label": "Soria"
      },
      {
        "value": "SS",
        "label": "Gipuzkoa"
      },
      {
        "value": "T",
        "label": "Tarragona"
      },
      {
        "value": "TE",
        "label": "Teruel"
      },
      {
        "value": "TF",
        "label": "Santa Cruz de Tenerife"
      },
      {
        "value": "TO",
        "label": "Toledo"
      },
      {
        "value": "V",
        "label": "Valencia"
      },
      {
        "value": "VA",
        "label": "Valladolid"
      },
      {
        "value": "VC",
        "label": "Valenciana, Comunidad"
      },
      {
        "value": "VI",
        "label": "Álava"
      },
      {
        "value": "Z",
        "label": "Zaragoza"
      },
      {
        "value": "ZA",
        "label": "Zamora"
      }
    ]
  },
  {
    "value": "ET",
    "label": "Ethiopia",
    "states": [
      {
        "value": "AA",
        "label": "Addis Ababa"
      },
      {
        "value": "AF",
        "label": "Afar"
      },
      {
        "value": "AM",
        "label": "Amara"
      },
      {
        "value": "BE",
        "label": "Benshangul-Gumaz"
      },
      {
        "value": "DD",
        "label": "Dire Dawa"
      },
      {
        "value": "GA",
        "label": "Gambela Peoples"
      },
      {
        "value": "HA",
        "label": "Harari People"
      },
      {
        "value": "OR",
        "label": "Oromia"
      },
      {
        "value": "SI",
        "label": "Sidama"
      },
      {
        "value": "SN",
        "label": "Southern Nations, Nationalities and Peoples"
      },
      {
        "value": "SO",
        "label": "Somali"
      },
      {
        "value": "SW",
        "label": "Southwest Ethiopia Peoples"
      },
      {
        "value": "TI",
        "label": "Tigrai"
      }
    ]
  },
  {
    "value": "FI",
    "label": "Finland",
    "states": [
      {
        "value": "01",
        "label": "Ahvenanmaan maakunta"
      },
      {
        "value": "02",
        "label": "Etelä-Karjala"
      },
      {
        "value": "03",
        "label": "Etelä-Pohjanmaa"
      },
      {
        "value": "04",
        "label": "Etelä-Savo"
      },
      {
        "value": "05",
        "label": "Kainuu"
      },
      {
        "value": "06",
        "label": "Kanta-Häme"
      },
      {
        "value": "07",
        "label": "Keski-Pohjanmaa"
      },
      {
        "value": "08",
        "label": "Keski-Suomi"
      },
      {
        "value": "09",
        "label": "Kymenlaakso"
      },
      {
        "value": "10",
        "label": "Lappi"
      },
      {
        "value": "11",
        "label": "Pirkanmaa"
      },
      {
        "value": "12",
        "label": "Pohjanmaa"
      },
      {
        "value": "13",
        "label": "Pohjois-Karjala"
      },
      {
        "value": "14",
        "label": "Pohjois-Pohjanmaa"
      },
      {
        "value": "15",
        "label": "Pohjois-Savo"
      },
      {
        "value": "16",
        "label": "Päijät-Häme"
      },
      {
        "value": "17",
        "label": "Satakunta"
      },
      {
        "value": "18",
        "label": "Uusimaa"
      },
      {
        "value": "19",
        "label": "Varsinais-Suomi"
      }
    ]
  },
  {
    "value": "FJ",
    "label": "Fiji",
    "states": [
      {
        "value": "01",
        "label": "Ba"
      },
      {
        "value": "02",
        "label": "Bua"
      },
      {
        "value": "03",
        "label": "Cakaudrove"
      },
      {
        "value": "04",
        "label": "Kadavu"
      },
      {
        "value": "05",
        "label": "Lau"
      },
      {
        "value": "06",
        "label": "Lomaiviti"
      },
      {
        "value": "07",
        "label": "Macuata"
      },
      {
        "value": "08",
        "label": "Nadroga and Navosa"
      },
      {
        "value": "09",
        "label": "Naitasiri"
      },
      {
        "value": "10",
        "label": "Namosi"
      },
      {
        "value": "11",
        "label": "Ra"
      },
      {
        "value": "12",
        "label": "Rewa"
      },
      {
        "value": "13",
        "label": "Serua"
      },
      {
        "value": "14",
        "label": "Tailevu"
      },
      {
        "value": "C",
        "label": "Central"
      },
      {
        "value": "E",
        "label": "Eastern"
      },
      {
        "value": "N",
        "label": "Northern"
      },
      {
        "value": "R",
        "label": "Rotuma"
      },
      {
        "value": "W",
        "label": "Western"
      }
    ]
  },
  {
    "value": "FK",
    "label": "Falkland Islands (Malvinas)",
    "states": []
  },
  {
    "value": "FO",
    "label": "Faroe Islands",
    "states": []
  },
  {
    "value": "FR",
    "label": "France",
    "states": [
      {
        "value": "01",
        "label": "Ain"
      },
      {
        "value": "02",
        "label": "Aisne"
      },
      {
        "value": "03",
        "label": "Allier"
      },
      {
        "value": "04",
        "label": "Alpes-de-Haute-Provence"
      },
      {
        "value": "05",
        "label": "Hautes-Alpes"
      },
      {
        "value": "06",
        "label": "Alpes-Maritimes"
      },
      {
        "value": "07",
        "label": "Ardèche"
      },
      {
        "value": "08",
        "label": "Ardennes"
      },
      {
        "value": "09",
        "label": "Ariège"
      },
      {
        "value": "10",
        "label": "Aube"
      },
      {
        "value": "11",
        "label": "Aude"
      },
      {
        "value": "12",
        "label": "Aveyron"
      },
      {
        "value": "13",
        "label": "Bouches-du-Rhône"
      },
      {
        "value": "14",
        "label": "Calvados"
      },
      {
        "value": "15",
        "label": "Cantal"
      },
      {
        "value": "16",
        "label": "Charente"
      },
      {
        "value": "17",
        "label": "Charente-Maritime"
      },
      {
        "value": "18",
        "label": "Cher"
      },
      {
        "value": "19",
        "label": "Corrèze"
      },
      {
        "value": "20R",
        "label": "Corse"
      },
      {
        "value": "21",
        "label": "Côte-d'Or"
      },
      {
        "value": "22",
        "label": "Côtes-d'Armor"
      },
      {
        "value": "23",
        "label": "Creuse"
      },
      {
        "value": "24",
        "label": "Dordogne"
      },
      {
        "value": "25",
        "label": "Doubs"
      },
      {
        "value": "26",
        "label": "Drôme"
      },
      {
        "value": "27",
        "label": "Eure"
      },
      {
        "value": "28",
        "label": "Eure-et-Loir"
      },
      {
        "value": "29",
        "label": "Finistère"
      },
      {
        "value": "2A",
        "label": "Corse-du-Sud"
      },
      {
        "value": "2B",
        "label": "Haute-Corse"
      },
      {
        "value": "30",
        "label": "Gard"
      },
      {
        "value": "31",
        "label": "Haute-Garonne"
      },
      {
        "value": "32",
        "label": "Gers"
      },
      {
        "value": "33",
        "label": "Gironde"
      },
      {
        "value": "34",
        "label": "Hérault"
      },
      {
        "value": "35",
        "label": "Ille-et-Vilaine"
      },
      {
        "value": "36",
        "label": "Indre"
      },
      {
        "value": "37",
        "label": "Indre-et-Loire"
      },
      {
        "value": "38",
        "label": "Isère"
      },
      {
        "value": "39",
        "label": "Jura"
      },
      {
        "value": "40",
        "label": "Landes"
      },
      {
        "value": "41",
        "label": "Loir-et-Cher"
      },
      {
        "value": "42",
        "label": "Loire"
      },
      {
        "value": "43",
        "label": "Haute-Loire"
      },
      {
        "value": "44",
        "label": "Loire-Atlantique"
      },
      {
        "value": "45",
        "label": "Loiret"
      },
      {
        "value": "46",
        "label": "Lot"
      },
      {
        "value": "47",
        "label": "Lot-et-Garonne"
      },
      {
        "value": "48",
        "label": "Lozère"
      },
      {
        "value": "49",
        "label": "Maine-et-Loire"
      },
      {
        "value": "50",
        "label": "Manche"
      },
      {
        "value": "51",
        "label": "Marne"
      },
      {
        "value": "52",
        "label": "Haute-Marne"
      },
      {
        "value": "53",
        "label": "Mayenne"
      },
      {
        "value": "54",
        "label": "Meurthe-et-Moselle"
      },
      {
        "value": "55",
        "label": "Meuse"
      },
      {
        "value": "56",
        "label": "Morbihan"
      },
      {
        "value": "57",
        "label": "Moselle"
      },
      {
        "value": "58",
        "label": "Nièvre"
      },
      {
        "value": "59",
        "label": "Nord"
      },
      {
        "value": "60",
        "label": "Oise"
      },
      {
        "value": "61",
        "label": "Orne"
      },
      {
        "value": "62",
        "label": "Pas-de-Calais"
      },
      {
        "value": "63",
        "label": "Puy-de-Dôme"
      },
      {
        "value": "64",
        "label": "Pyrénées-Atlantiques"
      },
      {
        "value": "65",
        "label": "Hautes-Pyrénées"
      },
      {
        "value": "66",
        "label": "Pyrénées-Orientales"
      },
      {
        "value": "67",
        "label": "Bas-Rhin"
      },
      {
        "value": "68",
        "label": "Haut-Rhin"
      },
      {
        "value": "69",
        "label": "Rhône"
      },
      {
        "value": "69M",
        "label": "Métropole de Lyon"
      },
      {
        "value": "6AE",
        "label": "Alsace"
      },
      {
        "value": "70",
        "label": "Haute-Saône"
      },
      {
        "value": "71",
        "label": "Saône-et-Loire"
      },
      {
        "value": "72",
        "label": "Sarthe"
      },
      {
        "value": "73",
        "label": "Savoie"
      },
      {
        "value": "74",
        "label": "Haute-Savoie"
      },
      {
        "value": "75C",
        "label": "Paris"
      },
      {
        "value": "76",
        "label": "Seine-Maritime"
      },
      {
        "value": "77",
        "label": "Seine-et-Marne"
      },
      {
        "value": "78",
        "label": "Yvelines"
      },
      {
        "value": "79",
        "label": "Deux-Sèvres"
      },
      {
        "value": "80",
        "label": "Somme"
      },
      {
        "value": "81",
        "label": "Tarn"
      },
      {
        "value": "82",
        "label": "Tarn-et-Garonne"
      },
      {
        "value": "83",
        "label": "Var"
      },
      {
        "value": "84",
        "label": "Vaucluse"
      },
      {
        "value": "85",
        "label": "Vendée"
      },
      {
        "value": "86",
        "label": "Vienne"
      },
      {
        "value": "87",
        "label": "Haute-Vienne"
      },
      {
        "value": "88",
        "label": "Vosges"
      },
      {
        "value": "89",
        "label": "Yonne"
      },
      {
        "value": "90",
        "label": "Territoire de Belfort"
      },
      {
        "value": "91",
        "label": "Essonne"
      },
      {
        "value": "92",
        "label": "Hauts-de-Seine"
      },
      {
        "value": "93",
        "label": "Seine-Saint-Denis"
      },
      {
        "value": "94",
        "label": "Val-de-Marne"
      },
      {
        "value": "95",
        "label": "Val-d'Oise"
      },
      {
        "value": "971",
        "label": "Guadeloupe"
      },
      {
        "value": "972",
        "label": "Martinique"
      },
      {
        "value": "973",
        "label": "Guyane"
      },
      {
        "value": "974",
        "label": "La Réunion"
      },
      {
        "value": "976",
        "label": "Mayotte"
      },
      {
        "value": "ARA",
        "label": "Auvergne-Rhône-Alpes"
      },
      {
        "value": "BFC",
        "label": "Bourgogne-Franche-Comté"
      },
      {
        "value": "BL",
        "label": "Saint-Barthélemy"
      },
      {
        "value": "BRE",
        "label": "Bretagne"
      },
      {
        "value": "CP",
        "label": "Clipperton"
      },
      {
        "value": "CVL",
        "label": "Centre-Val de Loire"
      },
      {
        "value": "GES",
        "label": "Grand-Est"
      },
      {
        "value": "HDF",
        "label": "Hauts-de-France"
      },
      {
        "value": "IDF",
        "label": "Île-de-France"
      },
      {
        "value": "MF",
        "label": "Saint-Martin"
      },
      {
        "value": "NAQ",
        "label": "Nouvelle-Aquitaine"
      },
      {
        "value": "NC",
        "label": "Nouvelle-Calédonie"
      },
      {
        "value": "NOR",
        "label": "Normandie"
      },
      {
        "value": "OCC",
        "label": "Occitanie"
      },
      {
        "value": "PAC",
        "label": "Provence-Alpes-Côte-d’Azur"
      },
      {
        "value": "PDL",
        "label": "Pays-de-la-Loire"
      },
      {
        "value": "PF",
        "label": "Polynésie française"
      },
      {
        "value": "PM",
        "label": "Saint-Pierre-et-Miquelon"
      },
      {
        "value": "TF",
        "label": "Terres australes françaises"
      },
      {
        "value": "WF",
        "label": "Wallis-et-Futuna"
      }
    ]
  },
  {
    "value": "GA",
    "label": "Gabon",
    "states": [
      {
        "value": "1",
        "label": "Estuaire"
      },
      {
        "value": "2",
        "label": "Haut-Ogooué"
      },
      {
        "value": "3",
        "label": "Moyen-Ogooué"
      },
      {
        "value": "4",
        "label": "Ngounié"
      },
      {
        "value": "5",
        "label": "Nyanga"
      },
      {
        "value": "6",
        "label": "Ogooué-Ivindo"
      },
      {
        "value": "7",
        "label": "Ogooué-Lolo"
      },
      {
        "value": "8",
        "label": "Ogooué-Maritime"
      },
      {
        "value": "9",
        "label": "Woleu-Ntem"
      }
    ]
  },
  {
    "value": "GB",
    "label": "United Kingdom",
    "states": [
      {
        "value": "ABC",
        "label": "Armagh City, Banbridge and Craigavon"
      },
      {
        "value": "ABD",
        "label": "Aberdeenshire"
      },
      {
        "value": "ABE",
        "label": "Aberdeen City"
      },
      {
        "value": "AGB",
        "label": "Argyll and Bute"
      },
      {
        "value": "AGY",
        "label": "Isle of Anglesey"
      },
      {
        "value": "AND",
        "label": "Ards and North Down"
      },
      {
        "value": "ANN",
        "label": "Antrim and Newtownabbey"
      },
      {
        "value": "ANS",
        "label": "Angus"
      },
      {
        "value": "BAS",
        "label": "Bath and North East Somerset"
      },
      {
        "value": "BBD",
        "label": "Blackburn with Darwen"
      },
      {
        "value": "BCP",
        "label": "Bournemouth, Christchurch and Poole"
      },
      {
        "value": "BDF",
        "label": "Bedford"
      },
      {
        "value": "BDG",
        "label": "Barking and Dagenham"
      },
      {
        "value": "BEN",
        "label": "Brent"
      },
      {
        "value": "BEX",
        "label": "Bexley"
      },
      {
        "value": "BFS",
        "label": "Belfast City"
      },
      {
        "value": "BGE",
        "label": "Bridgend"
      },
      {
        "value": "BGW",
        "label": "Blaenau Gwent"
      },
      {
        "value": "BIR",
        "label": "Birmingham"
      },
      {
        "value": "BKM",
        "label": "Buckinghamshire"
      },
      {
        "value": "BNE",
        "label": "Barnet"
      },
      {
        "value": "BNH",
        "label": "Brighton and Hove"
      },
      {
        "value": "BNS",
        "label": "Barnsley"
      },
      {
        "value": "BOL",
        "label": "Bolton"
      },
      {
        "value": "BPL",
        "label": "Blackpool"
      },
      {
        "value": "BRC",
        "label": "Bracknell Forest"
      },
      {
        "value": "BRD",
        "label": "Bradford"
      },
      {
        "value": "BRY",
        "label": "Bromley"
      },
      {
        "value": "BST",
        "label": "Bristol, City of"
      },
      {
        "value": "BUR",
        "label": "Bury"
      },
      {
        "value": "CAM",
        "label": "Cambridgeshire"
      },
      {
        "value": "CAY",
        "label": "Caerphilly"
      },
      {
        "value": "CBF",
        "label": "Central Bedfordshire"
      },
      {
        "value": "CCG",
        "label": "Causeway Coast and Glens"
      },
      {
        "value": "CGN",
        "label": "Ceredigion"
      },
      {
        "value": "CHE",
        "label": "Cheshire East"
      },
      {
        "value": "CHW",
        "label": "Cheshire West and Chester"
      },
      {
        "value": "CLD",
        "label": "Calderdale"
      },
      {
        "value": "CLK",
        "label": "Clackmannanshire"
      },
      {
        "value": "CMA",
        "label": "Cumbria"
      },
      {
        "value": "CMD",
        "label": "Camden"
      },
      {
        "value": "CMN",
        "label": "Carmarthenshire"
      },
      {
        "value": "CON",
        "label": "Cornwall"
      },
      {
        "value": "COV",
        "label": "Coventry"
      },
      {
        "value": "CRF",
        "label": "Cardiff"
      },
      {
        "value": "CRY",
        "label": "Croydon"
      },
      {
        "value": "CWY",
        "label": "Conwy"
      },
      {
        "value": "DAL",
        "label": "Darlington"
      },
      {
        "value": "DBY",
        "label": "Derbyshire"
      },
      {
        "value": "DEN",
        "label": "Denbighshire"
      },
      {
        "value": "DER",
        "label": "Derby"
      },
      {
        "value": "DEV",
        "label": "Devon"
      },
      {
        "value": "DGY",
        "label": "Dumfries and Galloway"
      },
      {
        "value": "DNC",
        "label": "Doncaster"
      },
      {
        "value": "DND",
        "label": "Dundee City"
      },
      {
        "value": "DOR",
        "label": "Dorset"
      },
      {
        "value": "DRS",
        "label": "Derry and Strabane"
      },
      {
        "value": "DUD",
        "label": "Dudley"
      },
      {
        "value": "DUR",
        "label": "Durham, County"
      },
      {
        "value": "EAL",
        "label": "Ealing"
      },
      {
        "value": "EAY",
        "label": "East Ayrshire"
      },
      {
        "value": "EDH",
        "label": "Edinburgh, City of"
      },
      {
        "value": "EDU",
        "label": "East Dunbartonshire"
      },
      {
        "value": "ELN",
        "label": "East Lothian"
      },
      {
        "value": "ELS",
        "label": "Eilean Siar"
      },
      {
        "value": "ENF",
        "label": "Enfield"
      },
      {
        "value": "ENG",
        "label": "England"
      },
      {
        "value": "ERW",
        "label": "East Renfrewshire"
      },
      {
        "value": "ERY",
        "label": "East Riding of Yorkshire"
      },
      {
        "value": "ESS",
        "label": "Essex"
      },
      {
        "value": "ESX",
        "label": "East Sussex"
      },
      {
        "value": "FAL",
        "label": "Falkirk"
      },
      {
        "value": "FIF",
        "label": "Fife"
      },
      {
        "value": "FLN",
        "label": "Flintshire"
      },
      {
        "value": "FMO",
        "label": "Fermanagh and Omagh"
      },
      {
        "value": "GAT",
        "label": "Gateshead"
      },
      {
        "value": "GLG",
        "label": "Glasgow City"
      },
      {
        "value": "GLS",
        "label": "Gloucestershire"
      },
      {
        "value": "GRE",
        "label": "Greenwich"
      },
      {
        "value": "GWN",
        "label": "Gwynedd"
      },
      {
        "value": "HAL",
        "label": "Halton"
      },
      {
        "value": "HAM",
        "label": "Hampshire"
      },
      {
        "value": "HAV",
        "label": "Havering"
      },
      {
        "value": "HCK",
        "label": "Hackney"
      },
      {
        "value": "HEF",
        "label": "Herefordshire"
      },
      {
        "value": "HIL",
        "label": "Hillingdon"
      },
      {
        "value": "HLD",
        "label": "Highland"
      },
      {
        "value": "HMF",
        "label": "Hammersmith and Fulham"
      },
      {
        "value": "HNS",
        "label": "Hounslow"
      },
      {
        "value": "HPL",
        "label": "Hartlepool"
      },
      {
        "value": "HRT",
        "label": "Hertfordshire"
      },
      {
        "value": "HRW",
        "label": "Harrow"
      },
      {
        "value": "HRY",
        "label": "Haringey"
      },
      {
        "value": "IOS",
        "label": "Isles of Scilly"
      },
      {
        "value": "IOW",
        "label": "Isle of Wight"
      },
      {
        "value": "ISL",
        "label": "Islington"
      },
      {
        "value": "IVC",
        "label": "Inverclyde"
      },
      {
        "value": "KEC",
        "label": "Kensington and Chelsea"
      },
      {
        "value": "KEN",
        "label": "Kent"
      },
      {
        "value": "KHL",
        "label": "Kingston upon Hull"
      },
      {
        "value": "KIR",
        "label": "Kirklees"
      },
      {
        "value": "KTT",
        "label": "Kingston upon Thames"
      },
      {
        "value": "KWL",
        "label": "Knowsley"
      },
      {
        "value": "LAN",
        "label": "Lancashire"
      },
      {
        "value": "LBC",
        "label": "Lisburn and Castlereagh"
      },
      {
        "value": "LBH",
        "label": "Lambeth"
      },
      {
        "value": "LCE",
        "label": "Leicester"
      },
      {
        "value": "LDS",
        "label": "Leeds"
      },
      {
        "value": "LEC",
        "label": "Leicestershire"
      },
      {
        "value": "LEW",
        "label": "Lewisham"
      },
      {
        "value": "LIN",
        "label": "Lincolnshire"
      },
      {
        "value": "LIV",
        "label": "Liverpool"
      },
      {
        "value": "LND",
        "label": "London, City of"
      },
      {
        "value": "LUT",
        "label": "Luton"
      },
      {
        "value": "MAN",
        "label": "Manchester"
      },
      {
        "value": "MDB",
        "label": "Middlesbrough"
      },
      {
        "value": "MDW",
        "label": "Medway"
      },
      {
        "value": "MEA",
        "label": "Mid and East Antrim"
      },
      {
        "value": "MIK",
        "label": "Milton Keynes"
      },
      {
        "value": "MLN",
        "label": "Midlothian"
      },
      {
        "value": "MON",
        "label": "Monmouthshire"
      },
      {
        "value": "MRT",
        "label": "Merton"
      },
      {
        "value": "MRY",
        "label": "Moray"
      },
      {
        "value": "MTY",
        "label": "Merthyr Tydfil"
      },
      {
        "value": "MUL",
        "label": "Mid-Ulster"
      },
      {
        "value": "NAY",
        "label": "North Ayrshire"
      },
      {
        "value": "NBL",
        "label": "Northumberland"
      },
      {
        "value": "NEL",
        "label": "North East Lincolnshire"
      },
      {
        "value": "NET",
        "label": "Newcastle upon Tyne"
      },
      {
        "value": "NFK",
        "label": "Norfolk"
      },
      {
        "value": "NGM",
        "label": "Nottingham"
      },
      {
        "value": "NIR",
        "label": "Northern Ireland"
      },
      {
        "value": "NLK",
        "label": "North Lanarkshire"
      },
      {
        "value": "NLN",
        "label": "North Lincolnshire"
      },
      {
        "value": "NMD",
        "label": "Newry, Mourne and Down"
      },
      {
        "value": "NNH",
        "label": "North Northamptonshire"
      },
      {
        "value": "NSM",
        "label": "North Somerset"
      },
      {
        "value": "NTL",
        "label": "Neath Port Talbot"
      },
      {
        "value": "NTT",
        "label": "Nottinghamshire"
      },
      {
        "value": "NTY",
        "label": "North Tyneside"
      },
      {
        "value": "NWM",
        "label": "Newham"
      },
      {
        "value": "NWP",
        "label": "Newport"
      },
      {
        "value": "NYK",
        "label": "North Yorkshire"
      },
      {
        "value": "OLD",
        "label": "Oldham"
      },
      {
        "value": "ORK",
        "label": "Orkney Islands"
      },
      {
        "value": "OXF",
        "label": "Oxfordshire"
      },
      {
        "value": "PEM",
        "label": "Pembrokeshire"
      },
      {
        "value": "PKN",
        "label": "Perth and Kinross"
      },
      {
        "value": "PLY",
        "label": "Plymouth"
      },
      {
        "value": "POR",
        "label": "Portsmouth"
      },
      {
        "value": "POW",
        "label": "Powys"
      },
      {
        "value": "PTE",
        "label": "Peterborough"
      },
      {
        "value": "RCC",
        "label": "Redcar and Cleveland"
      },
      {
        "value": "RCH",
        "label": "Rochdale"
      },
      {
        "value": "RCT",
        "label": "Rhondda Cynon Taff"
      },
      {
        "value": "RDB",
        "label": "Redbridge"
      },
      {
        "value": "RDG",
        "label": "Reading"
      },
      {
        "value": "RFW",
        "label": "Renfrewshire"
      },
      {
        "value": "RIC",
        "label": "Richmond upon Thames"
      },
      {
        "value": "ROT",
        "label": "Rotherham"
      },
      {
        "value": "RUT",
        "label": "Rutland"
      },
      {
        "value": "SAW",
        "label": "Sandwell"
      },
      {
        "value": "SAY",
        "label": "South Ayrshire"
      },
      {
        "value": "SCB",
        "label": "Scottish Borders"
      },
      {
        "value": "SCT",
        "label": "Scotland"
      },
      {
        "value": "SFK",
        "label": "Suffolk"
      },
      {
        "value": "SFT",
        "label": "Sefton"
      },
      {
        "value": "SGC",
        "label": "South Gloucestershire"
      },
      {
        "value": "SHF",
        "label": "Sheffield"
      },
      {
        "value": "SHN",
        "label": "St. Helens"
      },
      {
        "value": "SHR",
        "label": "Shropshire"
      },
      {
        "value": "SKP",
        "label": "Stockport"
      },
      {
        "value": "SLF",
        "label": "Salford"
      },
      {
        "value": "SLG",
        "label": "Slough"
      },
      {
        "value": "SLK",
        "label": "South Lanarkshire"
      },
      {
        "value": "SND",
        "label": "Sunderland"
      },
      {
        "value": "SOL",
        "label": "Solihull"
      },
      {
        "value": "SOM",
        "label": "Somerset"
      },
      {
        "value": "SOS",
        "label": "Southend-on-Sea"
      },
      {
        "value": "SRY",
        "label": "Surrey"
      },
      {
        "value": "STE",
        "label": "Stoke-on-Trent"
      },
      {
        "value": "STG",
        "label": "Stirling"
      },
      {
        "value": "STH",
        "label": "Southampton"
      },
      {
        "value": "STN",
        "label": "Sutton"
      },
      {
        "value": "STS",
        "label": "Staffordshire"
      },
      {
        "value": "STT",
        "label": "Stockton-on-Tees"
      },
      {
        "value": "STY",
        "label": "South Tyneside"
      },
      {
        "value": "SWA",
        "label": "Swansea"
      },
      {
        "value": "SWD",
        "label": "Swindon"
      },
      {
        "value": "SWK",
        "label": "Southwark"
      },
      {
        "value": "TAM",
        "label": "Tameside"
      },
      {
        "value": "TFW",
        "label": "Telford and Wrekin"
      },
      {
        "value": "THR",
        "label": "Thurrock"
      },
      {
        "value": "TOB",
        "label": "Torbay"
      },
      {
        "value": "TOF",
        "label": "Torfaen"
      },
      {
        "value": "TRF",
        "label": "Trafford"
      },
      {
        "value": "TWH",
        "label": "Tower Hamlets"
      },
      {
        "value": "VGL",
        "label": "Vale of Glamorgan, The"
      },
      {
        "value": "WAR",
        "label": "Warwickshire"
      },
      {
        "value": "WBK",
        "label": "West Berkshire"
      },
      {
        "value": "WDU",
        "label": "West Dunbartonshire"
      },
      {
        "value": "WFT",
        "label": "Waltham Forest"
      },
      {
        "value": "WGN",
        "label": "Wigan"
      },
      {
        "value": "WIL",
        "label": "Wiltshire"
      },
      {
        "value": "WKF",
        "label": "Wakefield"
      },
      {
        "value": "WLL",
        "label": "Walsall"
      },
      {
        "value": "WLN",
        "label": "West Lothian"
      },
      {
        "value": "WLS",
        "label": "Wales"
      },
      {
        "value": "WLV",
        "label": "Wolverhampton"
      },
      {
        "value": "WND",
        "label": "Wandsworth"
      },
      {
        "value": "WNH",
        "label": "West Northamptonshire"
      },
      {
        "value": "WNM",
        "label": "Windsor and Maidenhead"
      },
      {
        "value": "WOK",
        "label": "Wokingham"
      },
      {
        "value": "WOR",
        "label": "Worcestershire"
      },
      {
        "value": "WRL",
        "label": "Wirral"
      },
      {
        "value": "WRT",
        "label": "Warrington"
      },
      {
        "value": "WRX",
        "label": "Wrexham"
      },
      {
        "value": "WSM",
        "label": "Westminster"
      },
      {
        "value": "WSX",
        "label": "West Sussex"
      },
      {
        "value": "YOR",
        "label": "York"
      },
      {
        "value": "ZET",
        "label": "Shetland Islands"
      }
    ]
  },
  {
    "value": "GD",
    "label": "Grenada",
    "states": [
      {
        "value": "01",
        "label": "Saint Andrew"
      },
      {
        "value": "02",
        "label": "Saint David"
      },
      {
        "value": "03",
        "label": "Saint George"
      },
      {
        "value": "04",
        "label": "Saint John"
      },
      {
        "value": "05",
        "label": "Saint Mark"
      },
      {
        "value": "06",
        "label": "Saint Patrick"
      },
      {
        "value": "10",
        "label": "Carriacou"
      }
    ]
  },
  {
    "value": "GE",
    "label": "Georgia",
    "states": [
      {
        "value": "AB",
        "label": "Abkhazia"
      },
      {
        "value": "AJ",
        "label": "Ajaria"
      },
      {
        "value": "GU",
        "label": "Guria"
      },
      {
        "value": "IM",
        "label": "Imereti"
      },
      {
        "value": "KA",
        "label": "K'akheti"
      },
      {
        "value": "KK",
        "label": "Kvemo Kartli"
      },
      {
        "value": "MM",
        "label": "Mtskheta-Mtianeti"
      },
      {
        "value": "RL",
        "label": "Rach'a-Lechkhumi-Kvemo Svaneti"
      },
      {
        "value": "SJ",
        "label": "Samtskhe-Javakheti"
      },
      {
        "value": "SK",
        "label": "Shida Kartli"
      },
      {
        "value": "SZ",
        "label": "Samegrelo-Zemo Svaneti"
      },
      {
        "value": "TB",
        "label": "Tbilisi"
      }
    ]
  },
  {
    "value": "GF",
    "label": "French Guiana",
    "states": []
  },
  {
    "value": "GG",
    "label": "Guernsey",
    "states": []
  },
  {
    "value": "GH",
    "label": "Ghana",
    "states": [
      {
        "value": "AA",
        "label": "Greater Accra"
      },
      {
        "value": "AF",
        "label": "Ahafo"
      },
      {
        "value": "AH",
        "label": "Ashanti"
      },
      {
        "value": "BE",
        "label": "Bono East"
      },
      {
        "value": "BO",
        "label": "Bono"
      },
      {
        "value": "CP",
        "label": "Central"
      },
      {
        "value": "EP",
        "label": "Eastern"
      },
      {
        "value": "NE",
        "label": "North East"
      },
      {
        "value": "NP",
        "label": "Northern"
      },
      {
        "value": "OT",
        "label": "Oti"
      },
      {
        "value": "SV",
        "label": "Savannah"
      },
      {
        "value": "TV",
        "label": "Volta"
      },
      {
        "value": "UE",
        "label": "Upper East"
      },
      {
        "value": "UW",
        "label": "Upper West"
      },
      {
        "value": "WN",
        "label": "Western North"
      },
      {
        "value": "WP",
        "label": "Western"
      }
    ]
  },
  {
    "value": "GI",
    "label": "Gibraltar",
    "states": []
  },
  {
    "value": "GL",
    "label": "Greenland",
    "states": [
      {
        "value": "AV",
        "label": "Avannaata Kommunia"
      },
      {
        "value": "KU",
        "label": "Kommune Kujalleq"
      },
      {
        "value": "QE",
        "label": "Qeqqata Kommunia"
      },
      {
        "value": "QT",
        "label": "Kommune Qeqertalik"
      },
      {
        "value": "SM",
        "label": "Kommuneqarfik Sermersooq"
      }
    ]
  },
  {
    "value": "GM",
    "label": "Gambia",
    "states": [
      {
        "value": "B",
        "label": "Banjul"
      },
      {
        "value": "L",
        "label": "Lower River"
      },
      {
        "value": "M",
        "label": "Central River"
      },
      {
        "value": "N",
        "label": "North Bank"
      },
      {
        "value": "U",
        "label": "Upper River"
      },
      {
        "value": "W",
        "label": "Western"
      }
    ]
  },
  {
    "value": "GN",
    "label": "Guinea",
    "states": [
      {
        "value": "BE",
        "label": "Beyla"
      },
      {
        "value": "BF",
        "label": "Boffa"
      },
      {
        "value": "BK",
        "label": "Boké"
      },
      {
        "value": "C",
        "label": "Conakry"
      },
      {
        "value": "CO",
        "label": "Coyah"
      },
      {
        "value": "DB",
        "label": "Dabola"
      },
      {
        "value": "DI",
        "label": "Dinguiraye"
      },
      {
        "value": "DL",
        "label": "Dalaba"
      },
      {
        "value": "DU",
        "label": "Dubréka"
      },
      {
        "value": "FA",
        "label": "Faranah"
      },
      {
        "value": "FO",
        "label": "Forécariah"
      },
      {
        "value": "FR",
        "label": "Fria"
      },
      {
        "value": "GA",
        "label": "Gaoual"
      },
      {
        "value": "GU",
        "label": "Guékédou"
      },
      {
        "value": "KA",
        "label": "Kankan"
      },
      {
        "value": "KB",
        "label": "Koubia"
      },
      {
        "value": "KD",
        "label": "Kindia"
      },
      {
        "value": "KE",
        "label": "Kérouané"
      },
      {
        "value": "KN",
        "label": "Koundara"
      },
      {
        "value": "KO",
        "label": "Kouroussa"
      },
      {
        "value": "KS",
        "label": "Kissidougou"
      },
      {
        "value": "LA",
        "label": "Labé"
      },
      {
        "value": "LE",
        "label": "Lélouma"
      },
      {
        "value": "LO",
        "label": "Lola"
      },
      {
        "value": "MC",
        "label": "Macenta"
      },
      {
        "value": "MD",
        "label": "Mandiana"
      },
      {
        "value": "ML",
        "label": "Mali"
      },
      {
        "value": "MM",
        "label": "Mamou"
      },
      {
        "value": "NZ",
        "label": "Nzérékoré"
      },
      {
        "value": "PI",
        "label": "Pita"
      },
      {
        "value": "SI",
        "label": "Siguiri"
      },
      {
        "value": "TE",
        "label": "Télimélé"
      },
      {
        "value": "TO",
        "label": "Tougué"
      },
      {
        "value": "YO",
        "label": "Yomou"
      }
    ]
  },
  {
    "value": "GP",
    "label": "Guadeloupe",
    "states": []
  },
  {
    "value": "GQ",
    "label": "Equatorial Guinea",
    "states": [
      {
        "value": "AN",
        "label": "Annobon"
      },
      {
        "value": "BN",
        "label": "Bioko Nord"
      },
      {
        "value": "BS",
        "label": "Bioko Sud"
      },
      {
        "value": "C",
        "label": "Région Continentale"
      },
      {
        "value": "CS",
        "label": "Centro Sud"
      },
      {
        "value": "DJ",
        "label": "Djibloho"
      },
      {
        "value": "I",
        "label": "Région Insulaire"
      },
      {
        "value": "KN",
        "label": "Kié-Ntem"
      },
      {
        "value": "LI",
        "label": "Littoral"
      },
      {
        "value": "WN",
        "label": "Wele-Nzas"
      }
    ]
  },
  {
    "value": "GR",
    "label": "Greece",
    "states": [
      {
        "value": "69",
        "label": "Ágion Óros"
      },
      {
        "value": "A",
        "label": "Anatolikí Makedonía kai Thráki"
      },
      {
        "value": "B",
        "label": "Kentrikí Makedonía"
      },
      {
        "value": "C",
        "label": "Dytikí Makedonía"
      },
      {
        "value": "D",
        "label": "Ípeiros"
      },
      {
        "value": "E",
        "label": "Thessalía"
      },
      {
        "value": "F",
        "label": "Ionía Nísia"
      },
      {
        "value": "G",
        "label": "Dytikí Elláda"
      },
      {
        "value": "H",
        "label": "Stereá Elláda"
      },
      {
        "value": "I",
        "label": "Attikí"
      },
      {
        "value": "J",
        "label": "Pelopónnisos"
      },
      {
        "value": "K",
        "label": "Vóreio Aigaío"
      },
      {
        "value": "L",
        "label": "Nótio Aigaío"
      },
      {
        "value": "M",
        "label": "Kríti"
      }
    ]
  },
  {
    "value": "GS",
    "label": "South Georgia and the South Sandwich Islands",
    "states": []
  },
  {
    "value": "GT",
    "label": "Guatemala",
    "states": [
      {
        "value": "01",
        "label": "Guatemala"
      },
      {
        "value": "02",
        "label": "El Progreso"
      },
      {
        "value": "03",
        "label": "Sacatepéquez"
      },
      {
        "value": "04",
        "label": "Chimaltenango"
      },
      {
        "value": "05",
        "label": "Escuintla"
      },
      {
        "value": "06",
        "label": "Santa Rosa"
      },
      {
        "value": "07",
        "label": "Sololá"
      },
      {
        "value": "08",
        "label": "Totonicapán"
      },
      {
        "value": "09",
        "label": "Quetzaltenango"
      },
      {
        "value": "10",
        "label": "Suchitepéquez"
      },
      {
        "value": "11",
        "label": "Retalhuleu"
      },
      {
        "value": "12",
        "label": "San Marcos"
      },
      {
        "value": "13",
        "label": "Huehuetenango"
      },
      {
        "value": "14",
        "label": "Quiché"
      },
      {
        "value": "15",
        "label": "Baja Verapaz"
      },
      {
        "value": "16",
        "label": "Alta Verapaz"
      },
      {
        "value": "17",
        "label": "Petén"
      },
      {
        "value": "18",
        "label": "Izabal"
      },
      {
        "value": "19",
        "label": "Zacapa"
      },
      {
        "value": "20",
        "label": "Chiquimula"
      },
      {
        "value": "21",
        "label": "Jalapa"
      },
      {
        "value": "22",
        "label": "Jutiapa"
      }
    ]
  },
  {
    "value": "GW",
    "label": "Guinea-Bissau",
    "states": [
      {
        "value": "BA",
        "label": "Bafatá"
      },
      {
        "value": "BL",
        "label": "Bolama / Bijagós"
      },
      {
        "value": "BM",
        "label": "Biombo"
      },
      {
        "value": "BS",
        "label": "SAB"
      },
      {
        "value": "CA",
        "label": "Cacheu"
      },
      {
        "value": "GA",
        "label": "Gabú"
      },
      {
        "value": "L",
        "label": "Leste"
      },
      {
        "value": "N",
        "label": "Norte"
      },
      {
        "value": "OI",
        "label": "Oio"
      },
      {
        "value": "QU",
        "label": "Quinara"
      },
      {
        "value": "S",
        "label": "Sul"
      },
      {
        "value": "TO",
        "label": "Tombali"
      }
    ]
  },
  {
    "value": "GY",
    "label": "Guyana",
    "states": [
      {
        "value": "BA",
        "label": "Barima-Waini"
      },
      {
        "value": "CU",
        "label": "Cuyuni-Mazaruni"
      },
      {
        "value": "DE",
        "label": "Demerara-Mahaica"
      },
      {
        "value": "EB",
        "label": "East Berbice-Corentyne"
      },
      {
        "value": "ES",
        "label": "Essequibo Islands-West Demerara"
      },
      {
        "value": "MA",
        "label": "Mahaica-Berbice"
      },
      {
        "value": "PM",
        "label": "Pomeroon-Supenaam"
      },
      {
        "value": "PT",
        "label": "Potaro-Siparuni"
      },
      {
        "value": "UD",
        "label": "Upper Demerara-Berbice"
      },
      {
        "value": "UT",
        "label": "Upper Takutu-Upper Essequibo"
      }
    ]
  },
  {
    "value": "HM",
    "label": "Heard Island and McDonald Islands",
    "states": []
  },
  {
    "value": "HN",
    "label": "Honduras",
    "states": [
      {
        "value": "AT",
        "label": "Atlántida"
      },
      {
        "value": "CH",
        "label": "Choluteca"
      },
      {
        "value": "CL",
        "label": "Colón"
      },
      {
        "value": "CM",
        "label": "Comayagua"
      },
      {
        "value": "CP",
        "label": "Copán"
      },
      {
        "value": "CR",
        "label": "Cortés"
      },
      {
        "value": "EP",
        "label": "El Paraíso"
      },
      {
        "value": "FM",
        "label": "Francisco Morazán"
      },
      {
        "value": "GD",
        "label": "Gracias a Dios"
      },
      {
        "value": "IB",
        "label": "Islas de la Bahía"
      },
      {
        "value": "IN",
        "label": "Intibucá"
      },
      {
        "value": "LE",
        "label": "Lempira"
      },
      {
        "value": "LP",
        "label": "La Paz"
      },
      {
        "value": "OC",
        "label": "Ocotepeque"
      },
      {
        "value": "OL",
        "label": "Olancho"
      },
      {
        "value": "SB",
        "label": "Santa Bárbara"
      },
      {
        "value": "VA",
        "label": "Valle"
      },
      {
        "value": "YO",
        "label": "Yoro"
      }
    ]
  },
  {
    "value": "HR",
    "label": "Croatia",
    "states": [
      {
        "value": "01",
        "label": "Zagrebačka županija"
      },
      {
        "value": "02",
        "label": "Krapinsko-zagorska županija"
      },
      {
        "value": "03",
        "label": "Sisačko-moslavačka županija"
      },
      {
        "value": "04",
        "label": "Karlovačka županija"
      },
      {
        "value": "05",
        "label": "Varaždinska županija"
      },
      {
        "value": "06",
        "label": "Koprivničko-križevačka županija"
      },
      {
        "value": "07",
        "label": "Bjelovarsko-bilogorska županija"
      },
      {
        "value": "08",
        "label": "Primorsko-goranska županija"
      },
      {
        "value": "09",
        "label": "Ličko-senjska županija"
      },
      {
        "value": "10",
        "label": "Virovitičko-podravska županija"
      },
      {
        "value": "11",
        "label": "Požeško-slavonska županija"
      },
      {
        "value": "12",
        "label": "Brodsko-posavska županija"
      },
      {
        "value": "13",
        "label": "Zadarska županija"
      },
      {
        "value": "14",
        "label": "Osječko-baranjska županija"
      },
      {
        "value": "15",
        "label": "Šibensko-kninska županija"
      },
      {
        "value": "16",
        "label": "Vukovarsko-srijemska županija"
      },
      {
        "value": "17",
        "label": "Splitsko-dalmatinska županija"
      },
      {
        "value": "18",
        "label": "Istarska županija"
      },
      {
        "value": "19",
        "label": "Dubrovačko-neretvanska županija"
      },
      {
        "value": "20",
        "label": "Međimurska županija"
      },
      {
        "value": "21",
        "label": "Grad Zagreb"
      }
    ]
  },
  {
    "value": "HT",
    "label": "Haiti",
    "states": [
      {
        "value": "AR",
        "label": "Artibonite"
      },
      {
        "value": "CE",
        "label": "Centre"
      },
      {
        "value": "GA",
        "label": "Grande’Anse"
      },
      {
        "value": "ND",
        "label": "Nord"
      },
      {
        "value": "NE",
        "label": "Nord-Est"
      },
      {
        "value": "NI",
        "label": "Nippes"
      },
      {
        "value": "NO",
        "label": "Nord-Ouest"
      },
      {
        "value": "OU",
        "label": "Ouest"
      },
      {
        "value": "SD",
        "label": "Sud"
      },
      {
        "value": "SE",
        "label": "Sud-Est"
      }
    ]
  },
  {
    "value": "HU",
    "label": "Hungary",
    "states": [
      {
        "value": "BA",
        "label": "Baranya"
      },
      {
        "value": "BC",
        "label": "Békéscsaba"
      },
      {
        "value": "BE",
        "label": "Békés"
      },
      {
        "value": "BK",
        "label": "Bács-Kiskun"
      },
      {
        "value": "BU",
        "label": "Budapest"
      },
      {
        "value": "BZ",
        "label": "Borsod-Abaúj-Zemplén"
      },
      {
        "value": "CS",
        "label": "Csongrád-Csanád"
      },
      {
        "value": "DE",
        "label": "Debrecen"
      },
      {
        "value": "DU",
        "label": "Dunaújváros"
      },
      {
        "value": "EG",
        "label": "Eger"
      },
      {
        "value": "ER",
        "label": "Érd"
      },
      {
        "value": "FE",
        "label": "Fejér"
      },
      {
        "value": "GS",
        "label": "Győr-Moson-Sopron"
      },
      {
        "value": "GY",
        "label": "Győr"
      },
      {
        "value": "HB",
        "label": "Hajdú-Bihar"
      },
      {
        "value": "HE",
        "label": "Heves"
      },
      {
        "value": "HV",
        "label": "Hódmezővásárhely"
      },
      {
        "value": "JN",
        "label": "Jász-Nagykun-Szolnok"
      },
      {
        "value": "KE",
        "label": "Komárom-Esztergom"
      },
      {
        "value": "KM",
        "label": "Kecskemét"
      },
      {
        "value": "KV",
        "label": "Kaposvár"
      },
      {
        "value": "MI",
        "label": "Miskolc"
      },
      {
        "value": "NK",
        "label": "Nagykanizsa"
      },
      {
        "value": "NO",
        "label": "Nógrád"
      },
      {
        "value": "NY",
        "label": "Nyíregyháza"
      },
      {
        "value": "PE",
        "label": "Pest"
      },
      {
        "value": "PS",
        "label": "Pécs"
      },
      {
        "value": "SD",
        "label": "Szeged"
      },
      {
        "value": "SF",
        "label": "Székesfehérvár"
      },
      {
        "value": "SH",
        "label": "Szombathely"
      },
      {
        "value": "SK",
        "label": "Szolnok"
      },
      {
        "value": "SN",
        "label": "Sopron"
      },
      {
        "value": "SO",
        "label": "Somogy"
      },
      {
        "value": "SS",
        "label": "Szekszárd"
      },
      {
        "value": "ST",
        "label": "Salgótarján"
      },
      {
        "value": "SZ",
        "label": "Szabolcs-Szatmár-Bereg"
      },
      {
        "value": "TB",
        "label": "Tatabánya"
      },
      {
        "value": "TO",
        "label": "Tolna"
      },
      {
        "value": "VA",
        "label": "Vas"
      },
      {
        "value": "VM",
        "label": "Veszprém"
      },
      {
        "value": "ZA",
        "label": "Zala"
      },
      {
        "value": "ZE",
        "label": "Zalaegerszeg"
      }
    ]
  },
  {
    "value": "ID",
    "label": "Indonesia",
    "states": [
      {
        "value": "AC",
        "label": "Aceh"
      },
      {
        "value": "BA",
        "label": "Bali"
      },
      {
        "value": "BB",
        "label": "Kepulauan Bangka Belitung"
      },
      {
        "value": "BE",
        "label": "Bengkulu"
      },
      {
        "value": "BT",
        "label": "Banten"
      },
      {
        "value": "GO",
        "label": "Gorontalo"
      },
      {
        "value": "JA",
        "label": "Jambi"
      },
      {
        "value": "JB",
        "label": "Jawa Barat"
      },
      {
        "value": "JI",
        "label": "Jawa Timur"
      },
      {
        "value": "JK",
        "label": "DKI Jakarta"
      },
      {
        "value": "JT",
        "label": "Jawa Tengah"
      },
      {
        "value": "JW",
        "label": "Jawa"
      },
      {
        "value": "KA",
        "label": "Kalimantan"
      },
      {
        "value": "KB",
        "label": "Kalimantan Barat"
      },
      {
        "value": "KI",
        "label": "Kalimantan Timur"
      },
      {
        "value": "KR",
        "label": "Kepulauan Riau"
      },
      {
        "value": "KS",
        "label": "Kalimantan Selatan"
      },
      {
        "value": "KT",
        "label": "Kalimantan Tengah"
      },
      {
        "value": "KU",
        "label": "Kalimantan Utara"
      },
      {
        "value": "LA",
        "label": "Lampung"
      },
      {
        "value": "ML",
        "label": "Maluku"
      },
      {
        "value": "MU",
        "label": "Maluku Utara"
      },
      {
        "value": "NB",
        "label": "Nusa Tenggara Barat"
      },
      {
        "value": "NT",
        "label": "Nusa Tenggara Timur"
      },
      {
        "value": "NU",
        "label": "Nusa Tenggara"
      },
      {
        "value": "PB",
        "label": "Papua Barat"
      },
      {
        "value": "PE",
        "label": "Papua Pengunungan"
      },
      {
        "value": "PP",
        "label": "Papua"
      },
      {
        "value": "PS",
        "label": "Papua Selatan"
      },
      {
        "value": "PT",
        "label": "Papua Tengah"
      },
      {
        "value": "RI",
        "label": "Riau"
      },
      {
        "value": "SA",
        "label": "Sulawesi Utara"
      },
      {
        "value": "SB",
        "label": "Sumatera Barat"
      },
      {
        "value": "SG",
        "label": "Sulawesi Tenggara"
      },
      {
        "value": "SL",
        "label": "Sulawesi"
      },
      {
        "value": "SM",
        "label": "Sumatera"
      },
      {
        "value": "SN",
        "label": "Sulawesi Selatan"
      },
      {
        "value": "SR",
        "label": "Sulawesi Barat"
      },
      {
        "value": "SS",
        "label": "Sumatera Selatan"
      },
      {
        "value": "ST",
        "label": "Sulawesi Tengah"
      },
      {
        "value": "SU",
        "label": "Sumatera Utara"
      },
      {
        "value": "YO",
        "label": "DI Yogya"
      }
    ]
  },
  {
    "value": "IE",
    "label": "Ireland",
    "states": [
      {
        "value": "C",
        "label": "Connaught"
      },
      {
        "value": "CE",
        "label": "Clare"
      },
      {
        "value": "CN",
        "label": "Cavan"
      },
      {
        "value": "CO",
        "label": "Cork"
      },
      {
        "value": "CW",
        "label": "Carlow"
      },
      {
        "value": "D",
        "label": "Dublin"
      },
      {
        "value": "DL",
        "label": "Donegal"
      },
      {
        "value": "G",
        "label": "Galway"
      },
      {
        "value": "KE",
        "label": "Kildare"
      },
      {
        "value": "KK",
        "label": "Kilkenny"
      },
      {
        "value": "KY",
        "label": "Kerry"
      },
      {
        "value": "L",
        "label": "Leinster"
      },
      {
        "value": "LD",
        "label": "Longford"
      },
      {
        "value": "LH",
        "label": "Louth"
      },
      {
        "value": "LK",
        "label": "Limerick"
      },
      {
        "value": "LM",
        "label": "Leitrim"
      },
      {
        "value": "LS",
        "label": "Laois"
      },
      {
        "value": "M",
        "label": "Munster"
      },
      {
        "value": "MH",
        "label": "Meath"
      },
      {
        "value": "MN",
        "label": "Monaghan"
      },
      {
        "value": "MO",
        "label": "Mayo"
      },
      {
        "value": "OY",
        "label": "Offaly"
      },
      {
        "value": "RN",
        "label": "Roscommon"
      },
      {
        "value": "SO",
        "label": "Sligo"
      },
      {
        "value": "TA",
        "label": "Tipperary"
      },
      {
        "value": "U",
        "label": "Ulster"
      },
      {
        "value": "WD",
        "label": "Waterford"
      },
      {
        "value": "WH",
        "label": "Westmeath"
      },
      {
        "value": "WW",
        "label": "Wicklow"
      },
      {
        "value": "WX",
        "label": "Wexford"
      }
    ]
  },
  {
    "value": "IL",
    "label": "Israel",
    "states": [
      {
        "value": "D",
        "label": "Southern"
      },
      {
        "value": "HA",
        "label": "Haifa"
      },
      {
        "value": "JM",
        "label": "Jerusalem"
      },
      {
        "value": "M",
        "label": "Central"
      },
      {
        "value": "TA",
        "label": "Tel Aviv"
      },
      {
        "value": "Z",
        "label": "Northern"
      }
    ]
  },
  {
    "value": "IM",
    "label": "Isle of Man",
    "states": []
  },
  {
    "value": "IN",
    "label": "India",
    "states": [
      {
        "value": "AN",
        "label": "Andaman and Nicobar Islands"
      },
      {
        "value": "AP",
        "label": "Andhra Pradesh"
      },
      {
        "value": "AR",
        "label": "Arunachal Pradesh"
      },
      {
        "value": "AS",
        "label": "Assam"
      },
      {
        "value": "BR",
        "label": "Bihar"
      },
      {
        "value": "CH",
        "label": "Chandigarh"
      },
      {
        "value": "CT",
        "label": "Chhattisgarh"
      },
      {
        "value": "DD",
        "label": "Daman and Diu"
      },
      {
        "value": "DH",
        "label": "Dādra and Nagar Haveli and Damān and Diu"
      },
      {
        "value": "DL",
        "label": "Delhi"
      },
      {
        "value": "DN",
        "label": "Dadra and Nagar Haveli"
      },
      {
        "value": "GA",
        "label": "Goa"
      },
      {
        "value": "GJ",
        "label": "Gujarat"
      },
      {
        "value": "HP",
        "label": "Himachal Pradesh"
      },
      {
        "value": "HR",
        "label": "Haryana"
      },
      {
        "value": "JH",
        "label": "Jharkhand"
      },
      {
        "value": "JK",
        "label": "Jammu and Kashmir"
      },
      {
        "value": "KA",
        "label": "Karnataka"
      },
      {
        "value": "KL",
        "label": "Kerala"
      },
      {
        "value": "LA",
        "label": "Ladākh"
      },
      {
        "value": "LD",
        "label": "Lakshadweep"
      },
      {
        "value": "MH",
        "label": "Maharashtra"
      },
      {
        "value": "ML",
        "label": "Meghalaya"
      },
      {
        "value": "MN",
        "label": "Manipur"
      },
      {
        "value": "MP",
        "label": "Madhya Pradesh"
      },
      {
        "value": "MZ",
        "label": "Mizoram"
      },
      {
        "value": "NL",
        "label": "Nagaland"
      },
      {
        "value": "OR",
        "label": "Odisha"
      },
      {
        "value": "PB",
        "label": "Punjab"
      },
      {
        "value": "PY",
        "label": "Puducherry"
      },
      {
        "value": "RJ",
        "label": "Rajasthan"
      },
      {
        "value": "SK",
        "label": "Sikkim"
      },
      {
        "value": "TG",
        "label": "Telangāna"
      },
      {
        "value": "TN",
        "label": "Tamil Nadu"
      },
      {
        "value": "TR",
        "label": "Tripura"
      },
      {
        "value": "UP",
        "label": "Uttar Pradesh"
      },
      {
        "value": "UT",
        "label": "Uttarakhand"
      },
      {
        "value": "WB",
        "label": "West Bengal"
      }
    ]
  },
  {
    "value": "IO",
    "label": "British Indian Ocean Territory",
    "states": []
  },
  {
    "value": "IQ",
    "label": "Iraq",
    "states": [
      {
        "value": "AN",
        "label": "Al Anbār"
      },
      {
        "value": "AR",
        "label": "Arbīl"
      },
      {
        "value": "BA",
        "label": "Al Başrah"
      },
      {
        "value": "BB",
        "label": "Bābil"
      },
      {
        "value": "BG",
        "label": "Baghdād"
      },
      {
        "value": "DA",
        "label": "Dahūk"
      },
      {
        "value": "DI",
        "label": "Diyālá"
      },
      {
        "value": "DQ",
        "label": "Dhī Qār"
      },
      {
        "value": "KA",
        "label": "Karbalā’"
      },
      {
        "value": "KI",
        "label": "Kirkūk"
      },
      {
        "value": "KR",
        "label": "Iqlīm Kūrdistān"
      },
      {
        "value": "MA",
        "label": "Maysān"
      },
      {
        "value": "MU",
        "label": "Al Muthanná"
      },
      {
        "value": "NA",
        "label": "An Najaf"
      },
      {
        "value": "NI",
        "label": "Nīnawá"
      },
      {
        "value": "QA",
        "label": "Al Qādisīyah"
      },
      {
        "value": "SD",
        "label": "Şalāḩ ad Dīn"
      },
      {
        "value": "SU",
        "label": "As Sulaymānīyah"
      },
      {
        "value": "WA",
        "label": "Wāsiţ"
      }
    ]
  },
  {
    "value": "IR",
    "label": "Iran, Islamic Republic of",
    "states": [
      {
        "value": "00",
        "label": "Markazī"
      },
      {
        "value": "01",
        "label": "Gīlān"
      },
      {
        "value": "02",
        "label": "Māzandarān"
      },
      {
        "value": "03",
        "label": "Āz̄ārbāyjān-e Shārqī"
      },
      {
        "value": "04",
        "label": "Āz̄ārbāyjān-e Ghārbī"
      },
      {
        "value": "05",
        "label": "Kermānshāh"
      },
      {
        "value": "06",
        "label": "Khūzestān"
      },
      {
        "value": "07",
        "label": "Fārs"
      },
      {
        "value": "08",
        "label": "Kermān"
      },
      {
        "value": "09",
        "label": "Khorāsān-e Raẕavī"
      },
      {
        "value": "10",
        "label": "Eşfahān"
      },
      {
        "value": "11",
        "label": "Sīstān va Balūchestān"
      },
      {
        "value": "12",
        "label": "Kordestān"
      },
      {
        "value": "13",
        "label": "Hamadān"
      },
      {
        "value": "14",
        "label": "Chahār Maḩāl va Bakhtīārī"
      },
      {
        "value": "15",
        "label": "Lorestān"
      },
      {
        "value": "16",
        "label": "Īlām"
      },
      {
        "value": "17",
        "label": "Kohgīlūyeh va Bowyer Aḩmad"
      },
      {
        "value": "18",
        "label": "Būshehr"
      },
      {
        "value": "19",
        "label": "Zanjān"
      },
      {
        "value": "20",
        "label": "Semnān"
      },
      {
        "value": "21",
        "label": "Yazd"
      },
      {
        "value": "22",
        "label": "Hormozgān"
      },
      {
        "value": "23",
        "label": "Tehrān"
      },
      {
        "value": "24",
        "label": "Ardabīl"
      },
      {
        "value": "25",
        "label": "Qom"
      },
      {
        "value": "26",
        "label": "Qazvīn"
      },
      {
        "value": "27",
        "label": "Golestān"
      },
      {
        "value": "28",
        "label": "Khorāsān-e Shomālī"
      },
      {
        "value": "29",
        "label": "Khorāsān-e Jonūbī"
      },
      {
        "value": "30",
        "label": "Alborz"
      }
    ]
  },
  {
    "value": "IS",
    "label": "Iceland",
    "states": [
      {
        "value": "1",
        "label": "Höfuðborgarsvæði"
      },
      {
        "value": "2",
        "label": "Suðurnes"
      },
      {
        "value": "3",
        "label": "Vesturland"
      },
      {
        "value": "4",
        "label": "Vestfirðir"
      },
      {
        "value": "5",
        "label": "Norðurland vestra"
      },
      {
        "value": "6",
        "label": "Norðurland eystra"
      },
      {
        "value": "7",
        "label": "Austurland"
      },
      {
        "value": "8",
        "label": "Suðurland"
      },
      {
        "value": "AKN",
        "label": "Akraneskaupstaður"
      },
      {
        "value": "AKU",
        "label": "Akureyrarbær"
      },
      {
        "value": "ARN",
        "label": "Árneshreppur"
      },
      {
        "value": "ASA",
        "label": "Ásahreppur"
      },
      {
        "value": "BLA",
        "label": "Bláskógabyggð"
      },
      {
        "value": "BOG",
        "label": "Borgarbyggð"
      },
      {
        "value": "BOL",
        "label": "Bolungarvíkurkaupstaður"
      },
      {
        "value": "DAB",
        "label": "Dalabyggð"
      },
      {
        "value": "DAV",
        "label": "Dalvíkurbyggð"
      },
      {
        "value": "EOM",
        "label": "Eyja- og Miklaholtshreppur"
      },
      {
        "value": "EYF",
        "label": "Eyjafjarðarsveit"
      },
      {
        "value": "FJD",
        "label": "Fjarðabyggð"
      },
      {
        "value": "FJL",
        "label": "Fjallabyggð"
      },
      {
        "value": "FLA",
        "label": "Flóahreppur"
      },
      {
        "value": "FLR",
        "label": "Fljótsdalshreppur"
      },
      {
        "value": "GAR",
        "label": "Garðabær"
      },
      {
        "value": "GOG",
        "label": "Grímsnes- og Grafningshreppur"
      },
      {
        "value": "GRN",
        "label": "Grindavíkurbær"
      },
      {
        "value": "GRU",
        "label": "Grundarfjarðarbær"
      },
      {
        "value": "GRY",
        "label": "Grýtubakkahreppur"
      },
      {
        "value": "HAF",
        "label": "Hafnarfjarðarkaupstaður"
      },
      {
        "value": "HRG",
        "label": "Hörgársveit"
      },
      {
        "value": "HRU",
        "label": "Hrunamannahreppur"
      },
      {
        "value": "HUG",
        "label": "Húnabyggð"
      },
      {
        "value": "HUV",
        "label": "Húnaþing vestra"
      },
      {
        "value": "HVA",
        "label": "Hvalfjarðarsveit"
      },
      {
        "value": "HVE",
        "label": "Hveragerðisbær"
      },
      {
        "value": "ISA",
        "label": "Ísafjarðarbær"
      },
      {
        "value": "KAL",
        "label": "Kaldrananeshreppur"
      },
      {
        "value": "KJO",
        "label": "Kjósarhreppur"
      },
      {
        "value": "KOP",
        "label": "Kópavogsbær"
      },
      {
        "value": "LAN",
        "label": "Langanesbyggð"
      },
      {
        "value": "MOS",
        "label": "Mosfellsbær"
      },
      {
        "value": "MUL",
        "label": "Múlaþing"
      },
      {
        "value": "MYR",
        "label": "Mýrdalshreppur"
      },
      {
        "value": "NOR",
        "label": "Norðurþing"
      },
      {
        "value": "RGE",
        "label": "Rangárþing eystra"
      },
      {
        "value": "RGY",
        "label": "Rangárþing ytra"
      },
      {
        "value": "RHH",
        "label": "Reykhólahreppur"
      },
      {
        "value": "RKN",
        "label": "Reykjanesbær"
      },
      {
        "value": "RKV",
        "label": "Reykjavíkurborg"
      },
      {
        "value": "SBT",
        "label": "Svalbarðsstrandarhreppur"
      },
      {
        "value": "SDN",
        "label": "Suðurnesjabær"
      },
      {
        "value": "SDV",
        "label": "Súðavíkurhreppur"
      },
      {
        "value": "SEL",
        "label": "Seltjarnarnesbær"
      },
      {
        "value": "SFA",
        "label": "Sveitarfélagið Árborg"
      },
      {
        "value": "SHF",
        "label": "Sveitarfélagið Hornafjörður"
      },
      {
        "value": "SKF",
        "label": "Skaftárhreppur"
      },
      {
        "value": "SKG",
        "label": "Skagabyggð"
      },
      {
        "value": "SKO",
        "label": "Skorradalshreppur"
      },
      {
        "value": "SKR",
        "label": "Skagafjörður"
      },
      {
        "value": "SNF",
        "label": "Snæfellsbær"
      },
      {
        "value": "SOG",
        "label": "Skeiða- og Gnúpverjahreppur"
      },
      {
        "value": "SOL",
        "label": "Sveitarfélagið Ölfus"
      },
      {
        "value": "SSS",
        "label": "Sveitarfélagið Skagaströnd"
      },
      {
        "value": "STR",
        "label": "Strandabyggð"
      },
      {
        "value": "STY",
        "label": "Stykkishólmsbær"
      },
      {
        "value": "SVG",
        "label": "Sveitarfélagið Vogar"
      },
      {
        "value": "TAL",
        "label": "Tálknafjarðarhreppur"
      },
      {
        "value": "THG",
        "label": "Þingeyjarsveit"
      },
      {
        "value": "TJO",
        "label": "Tjörneshreppur"
      },
      {
        "value": "VEM",
        "label": "Vestmannaeyjabær"
      },
      {
        "value": "VER",
        "label": "Vesturbyggð"
      },
      {
        "value": "VOP",
        "label": "Vopnafjarðarhreppur"
      }
    ]
  },
  {
    "value": "IT",
    "label": "Italy",
    "states": [
      {
        "value": "21",
        "label": "Piemonte"
      },
      {
        "value": "23",
        "label": "Valle d'Aosta"
      },
      {
        "value": "25",
        "label": "Lombardia"
      },
      {
        "value": "34",
        "label": "Veneto"
      },
      {
        "value": "36",
        "label": "Friuli Venezia Giulia"
      },
      {
        "value": "42",
        "label": "Liguria"
      },
      {
        "value": "45",
        "label": "Emilia-Romagna"
      },
      {
        "value": "52",
        "label": "Toscana"
      },
      {
        "value": "55",
        "label": "Umbria"
      },
      {
        "value": "57",
        "label": "Marche"
      },
      {
        "value": "62",
        "label": "Lazio"
      },
      {
        "value": "65",
        "label": "Abruzzo"
      },
      {
        "value": "67",
        "label": "Molise"
      },
      {
        "value": "72",
        "label": "Campania"
      },
      {
        "value": "75",
        "label": "Puglia"
      },
      {
        "value": "77",
        "label": "Basilicata"
      },
      {
        "value": "78",
        "label": "Calabria"
      },
      {
        "value": "82",
        "label": "Sicilia"
      },
      {
        "value": "88",
        "label": "Sardegna"
      },
      {
        "value": "AG",
        "label": "Agrigento"
      },
      {
        "value": "AL",
        "label": "Alessandria"
      },
      {
        "value": "AN",
        "label": "Ancona"
      },
      {
        "value": "AO",
        "label": "Aosta"
      },
      {
        "value": "AP",
        "label": "Ascoli Piceno"
      },
      {
        "value": "AQ",
        "label": "L'Aquila"
      },
      {
        "value": "AR",
        "label": "Arezzo"
      },
      {
        "value": "AT",
        "label": "Asti"
      },
      {
        "value": "AV",
        "label": "Avellino"
      },
      {
        "value": "BA",
        "label": "Bari"
      },
      {
        "value": "BG",
        "label": "Bergamo"
      },
      {
        "value": "BI",
        "label": "Biella"
      },
      {
        "value": "BL",
        "label": "Belluno"
      },
      {
        "value": "BN",
        "label": "Benevento"
      },
      {
        "value": "BO",
        "label": "Bologna"
      },
      {
        "value": "BR",
        "label": "Brindisi"
      },
      {
        "value": "BS",
        "label": "Brescia"
      },
      {
        "value": "BT",
        "label": "Barletta-Andria-Trani"
      },
      {
        "value": "BZ",
        "label": "Bolzano"
      },
      {
        "value": "CA",
        "label": "Cagliari"
      },
      {
        "value": "CB",
        "label": "Campobasso"
      },
      {
        "value": "CE",
        "label": "Caserta"
      },
      {
        "value": "CH",
        "label": "Chieti"
      },
      {
        "value": "CI",
        "label": "Carbonia-Iglesias"
      },
      {
        "value": "CL",
        "label": "Caltanissetta"
      },
      {
        "value": "CN",
        "label": "Cuneo"
      },
      {
        "value": "CO",
        "label": "Como"
      },
      {
        "value": "CR",
        "label": "Cremona"
      },
      {
        "value": "CS",
        "label": "Cosenza"
      },
      {
        "value": "CT",
        "label": "Catania"
      },
      {
        "value": "CZ",
        "label": "Catanzaro"
      },
      {
        "value": "EN",
        "label": "Enna"
      },
      {
        "value": "FC",
        "label": "Forlì-Cesena"
      },
      {
        "value": "FE",
        "label": "Ferrara"
      },
      {
        "value": "FG",
        "label": "Foggia"
      },
      {
        "value": "FI",
        "label": "Florence"
      },
      {
        "value": "FM",
        "label": "Fermo"
      },
      {
        "value": "FR",
        "label": "Frosinone"
      },
      {
        "value": "GE",
        "label": "Genoa"
      },
      {
        "value": "GO",
        "label": "Gorizia"
      },
      {
        "value": "GR",
        "label": "Grosseto"
      },
      {
        "value": "IM",
        "label": "Imperia"
      },
      {
        "value": "IS",
        "label": "Isernia"
      },
      {
        "value": "KR",
        "label": "Crotone"
      },
      {
        "value": "LC",
        "label": "Lecco"
      },
      {
        "value": "LE",
        "label": "Lecce"
      },
      {
        "value": "LI",
        "label": "Livorno"
      },
      {
        "value": "LO",
        "label": "Lodi"
      },
      {
        "value": "LT",
        "label": "Latina"
      },
      {
        "value": "LU",
        "label": "Lucca"
      },
      {
        "value": "MB",
        "label": "Monza and Brianza"
      },
      {
        "value": "MC",
        "label": "Macerata"
      },
      {
        "value": "ME",
        "label": "Messina"
      },
      {
        "value": "MI",
        "label": "Milan"
      },
      {
        "value": "MN",
        "label": "Mantua"
      },
      {
        "value": "MO",
        "label": "Modena"
      },
      {
        "value": "MS",
        "label": "Massa and Carrara"
      },
      {
        "value": "MT",
        "label": "Matera"
      },
      {
        "value": "NA",
        "label": "Naples"
      },
      {
        "value": "NO",
        "label": "Novara"
      },
      {
        "value": "NU",
        "label": "Nuoro"
      },
      {
        "value": "OG",
        "label": "Ogliastra"
      },
      {
        "value": "OR",
        "label": "Oristano"
      },
      {
        "value": "OT",
        "label": "Olbia-Tempio"
      },
      {
        "value": "PA",
        "label": "Palermo"
      },
      {
        "value": "PC",
        "label": "Piacenza"
      },
      {
        "value": "PD",
        "label": "Padua"
      },
      {
        "value": "PE",
        "label": "Pescara"
      },
      {
        "value": "PG",
        "label": "Perugia"
      },
      {
        "value": "PI",
        "label": "Pisa"
      },
      {
        "value": "PN",
        "label": "Pordenone"
      },
      {
        "value": "PO",
        "label": "Prato"
      },
      {
        "value": "PR",
        "label": "Parma"
      },
      {
        "value": "PT",
        "label": "Pistoia"
      },
      {
        "value": "PU",
        "label": "Pesaro and Urbino"
      },
      {
        "value": "PV",
        "label": "Pavia"
      },
      {
        "value": "PZ",
        "label": "Potenza"
      },
      {
        "value": "RA",
        "label": "Ravenna"
      },
      {
        "value": "RC",
        "label": "Reggio Calabria"
      },
      {
        "value": "RE",
        "label": "Reggio Emilia"
      },
      {
        "value": "RG",
        "label": "Ragusa"
      },
      {
        "value": "RI",
        "label": "Rieti"
      },
      {
        "value": "RM",
        "label": "Rome"
      },
      {
        "value": "RN",
        "label": "Rimini"
      },
      {
        "value": "RO",
        "label": "Rovigo"
      },
      {
        "value": "SA",
        "label": "Salerno"
      },
      {
        "value": "SI",
        "label": "Siena"
      },
      {
        "value": "SO",
        "label": "Sondrio"
      },
      {
        "value": "SP",
        "label": "La Spezia"
      },
      {
        "value": "SR",
        "label": "Syracuse"
      },
      {
        "value": "SS",
        "label": "Sassari"
      },
      {
        "value": "SU",
        "label": "Sud Sardegna"
      },
      {
        "value": "SV",
        "label": "Savona"
      },
      {
        "value": "TA",
        "label": "Taranto"
      },
      {
        "value": "TE",
        "label": "Teramo"
      },
      {
        "value": "TN",
        "label": "Trento"
      },
      {
        "value": "TO",
        "label": "Turin"
      },
      {
        "value": "TP",
        "label": "Trapani"
      },
      {
        "value": "TR",
        "label": "Terni"
      },
      {
        "value": "TS",
        "label": "Trieste"
      },
      {
        "value": "TV",
        "label": "Treviso"
      },
      {
        "value": "UD",
        "label": "Udine"
      },
      {
        "value": "VA",
        "label": "Varese"
      },
      {
        "value": "VB",
        "label": "Verbano-Cusio-Ossola"
      },
      {
        "value": "VC",
        "label": "Vercelli"
      },
      {
        "value": "VE",
        "label": "Venice"
      },
      {
        "value": "VI",
        "label": "Vicenza"
      },
      {
        "value": "VR",
        "label": "Verona"
      },
      {
        "value": "VS",
        "label": "Medio Campidano"
      },
      {
        "value": "VT",
        "label": "Viterbo"
      },
      {
        "value": "VV",
        "label": "Vibo Valentia"
      }
    ]
  },
  {
    "value": "JE",
    "label": "Jersey",
    "states": []
  },
  {
    "value": "JM",
    "label": "Jamaica",
    "states": [
      {
        "value": "01",
        "label": "Kingston"
      },
      {
        "value": "02",
        "label": "Saint Andrew"
      },
      {
        "value": "03",
        "label": "Saint Thomas"
      },
      {
        "value": "04",
        "label": "Portland"
      },
      {
        "value": "05",
        "label": "Saint Mary"
      },
      {
        "value": "06",
        "label": "Saint Ann"
      },
      {
        "value": "07",
        "label": "Trelawny"
      },
      {
        "value": "08",
        "label": "Saint James"
      },
      {
        "value": "09",
        "label": "Hanover"
      },
      {
        "value": "10",
        "label": "Westmoreland"
      },
      {
        "value": "11",
        "label": "Saint Elizabeth"
      },
      {
        "value": "12",
        "label": "Manchester"
      },
      {
        "value": "13",
        "label": "Clarendon"
      },
      {
        "value": "14",
        "label": "Saint Catherine"
      }
    ]
  },
  {
    "value": "JO",
    "label": "Jordan",
    "states": [
      {
        "value": "AJ",
        "label": "‘Ajlūn"
      },
      {
        "value": "AM",
        "label": "‘Ammān"
      },
      {
        "value": "AQ",
        "label": "Aqaba"
      },
      {
        "value": "AT",
        "label": "Aţ Ţafīlah"
      },
      {
        "value": "AZ",
        "label": "Az Zarqā’"
      },
      {
        "value": "BA",
        "label": "Al Balqā’"
      },
      {
        "value": "IR",
        "label": "Irbid"
      },
      {
        "value": "JA",
        "label": "Jarash"
      },
      {
        "value": "KA",
        "label": "Al Karak"
      },
      {
        "value": "MA",
        "label": "Al Mafraq"
      },
      {
        "value": "MD",
        "label": "Mādabā"
      },
      {
        "value": "MN",
        "label": "Ma‘ān"
      }
    ]
  },
  {
    "value": "JP",
    "label": "Japan",
    "states": [
      {
        "value": "01",
        "label": "Hokkaido"
      },
      {
        "value": "02",
        "label": "Aomori"
      },
      {
        "value": "03",
        "label": "Iwate"
      },
      {
        "value": "04",
        "label": "Miyagi"
      },
      {
        "value": "05",
        "label": "Akita"
      },
      {
        "value": "06",
        "label": "Yamagata"
      },
      {
        "value": "07",
        "label": "Fukushima"
      },
      {
        "value": "08",
        "label": "Ibaraki"
      },
      {
        "value": "09",
        "label": "Tochigi"
      },
      {
        "value": "10",
        "label": "Gunma"
      },
      {
        "value": "11",
        "label": "Saitama"
      },
      {
        "value": "12",
        "label": "Chiba"
      },
      {
        "value": "13",
        "label": "Tokyo"
      },
      {
        "value": "14",
        "label": "Kanagawa"
      },
      {
        "value": "15",
        "label": "Niigata"
      },
      {
        "value": "16",
        "label": "Toyama"
      },
      {
        "value": "17",
        "label": "Ishikawa"
      },
      {
        "value": "18",
        "label": "Fukui"
      },
      {
        "value": "19",
        "label": "Yamanashi"
      },
      {
        "value": "20",
        "label": "Nagano"
      },
      {
        "value": "21",
        "label": "Gifu"
      },
      {
        "value": "22",
        "label": "Shizuoka"
      },
      {
        "value": "23",
        "label": "Aichi"
      },
      {
        "value": "24",
        "label": "Mie"
      },
      {
        "value": "25",
        "label": "Shiga"
      },
      {
        "value": "26",
        "label": "Kyoto"
      },
      {
        "value": "27",
        "label": "Osaka"
      },
      {
        "value": "28",
        "label": "Hyogo"
      },
      {
        "value": "29",
        "label": "Nara"
      },
      {
        "value": "30",
        "label": "Wakayama"
      },
      {
        "value": "31",
        "label": "Tottori"
      },
      {
        "value": "32",
        "label": "Shimane"
      },
      {
        "value": "33",
        "label": "Okayama"
      },
      {
        "value": "34",
        "label": "Hiroshima"
      },
      {
        "value": "35",
        "label": "Yamaguchi"
      },
      {
        "value": "36",
        "label": "Tokushima"
      },
      {
        "value": "37",
        "label": "Kagawa"
      },
      {
        "value": "38",
        "label": "Ehime"
      },
      {
        "value": "39",
        "label": "Kochi"
      },
      {
        "value": "40",
        "label": "Fukuoka"
      },
      {
        "value": "41",
        "label": "Saga"
      },
      {
        "value": "42",
        "label": "Nagasaki"
      },
      {
        "value": "43",
        "label": "Kumamoto"
      },
      {
        "value": "44",
        "label": "Oita"
      },
      {
        "value": "45",
        "label": "Miyazaki"
      },
      {
        "value": "46",
        "label": "Kagoshima"
      },
      {
        "value": "47",
        "label": "Okinawa"
      }
    ]
  },
  {
    "value": "KE",
    "label": "Kenya",
    "states": [
      {
        "value": "01",
        "label": "Baringo"
      },
      {
        "value": "02",
        "label": "Bomet"
      },
      {
        "value": "03",
        "label": "Bungoma"
      },
      {
        "value": "04",
        "label": "Busia"
      },
      {
        "value": "05",
        "label": "Elgeyo/Marakwet"
      },
      {
        "value": "06",
        "label": "Embu"
      },
      {
        "value": "07",
        "label": "Garissa"
      },
      {
        "value": "08",
        "label": "Homa Bay"
      },
      {
        "value": "09",
        "label": "Isiolo"
      },
      {
        "value": "10",
        "label": "Kajiado"
      },
      {
        "value": "11",
        "label": "Kakamega"
      },
      {
        "value": "12",
        "label": "Kericho"
      },
      {
        "value": "13",
        "label": "Kiambu"
      },
      {
        "value": "14",
        "label": "Kilifi"
      },
      {
        "value": "15",
        "label": "Kirinyaga"
      },
      {
        "value": "16",
        "label": "Kisii"
      },
      {
        "value": "17",
        "label": "Kisumu"
      },
      {
        "value": "18",
        "label": "Kitui"
      },
      {
        "value": "19",
        "label": "Kwale"
      },
      {
        "value": "20",
        "label": "Laikipia"
      },
      {
        "value": "21",
        "label": "Lamu"
      },
      {
        "value": "22",
        "label": "Machakos"
      },
      {
        "value": "23",
        "label": "Makueni"
      },
      {
        "value": "24",
        "label": "Mandera"
      },
      {
        "value": "25",
        "label": "Marsabit"
      },
      {
        "value": "26",
        "label": "Meru"
      },
      {
        "value": "27",
        "label": "Migori"
      },
      {
        "value": "28",
        "label": "Mombasa"
      },
      {
        "value": "29",
        "label": "Murang'a"
      },
      {
        "value": "30",
        "label": "Nairobi City"
      },
      {
        "value": "31",
        "label": "Nakuru"
      },
      {
        "value": "32",
        "label": "Nandi"
      },
      {
        "value": "33",
        "label": "Narok"
      },
      {
        "value": "34",
        "label": "Nyamira"
      },
      {
        "value": "35",
        "label": "Nyandarua"
      },
      {
        "value": "36",
        "label": "Nyeri"
      },
      {
        "value": "37",
        "label": "Samburu"
      },
      {
        "value": "38",
        "label": "Siaya"
      },
      {
        "value": "39",
        "label": "Taita/Taveta"
      },
      {
        "value": "40",
        "label": "Tana River"
      },
      {
        "value": "41",
        "label": "Tharaka-Nithi"
      },
      {
        "value": "42",
        "label": "Trans Nzoia"
      },
      {
        "value": "43",
        "label": "Turkana"
      },
      {
        "value": "44",
        "label": "Uasin Gishu"
      },
      {
        "value": "45",
        "label": "Vihiga"
      },
      {
        "value": "46",
        "label": "Wajir"
      },
      {
        "value": "47",
        "label": "West Pokot"
      }
    ]
  },
  {
    "value": "KG",
    "label": "Kyrgyzstan",
    "states": [
      {
        "value": "B",
        "label": "Batken"
      },
      {
        "value": "C",
        "label": "Chüy"
      },
      {
        "value": "GB",
        "label": "Bishkek Shaary"
      },
      {
        "value": "GO",
        "label": "Osh Shaary"
      },
      {
        "value": "J",
        "label": "Jalal-Abad"
      },
      {
        "value": "N",
        "label": "Naryn"
      },
      {
        "value": "O",
        "label": "Osh"
      },
      {
        "value": "T",
        "label": "Talas"
      },
      {
        "value": "Y",
        "label": "Ysyk-Köl"
      }
    ]
  },
  {
    "value": "KH",
    "label": "Cambodia",
    "states": [
      {
        "value": "1",
        "label": "Banteay Meanchey"
      },
      {
        "value": "10",
        "label": "Kratie"
      },
      {
        "value": "11",
        "label": "Mondolkiri"
      },
      {
        "value": "12",
        "label": "Phnom Penh"
      },
      {
        "value": "13",
        "label": "Preah Vihear"
      },
      {
        "value": "14",
        "label": "Prey Veaeng"
      },
      {
        "value": "15",
        "label": "Pursat"
      },
      {
        "value": "16",
        "label": "Ratanakiri"
      },
      {
        "value": "17",
        "label": "Siem Reap"
      },
      {
        "value": "18",
        "label": "Sihanoukville"
      },
      {
        "value": "19",
        "label": "Stung Treng"
      },
      {
        "value": "2",
        "label": "Battambang"
      },
      {
        "value": "20",
        "label": "Svay Rieng"
      },
      {
        "value": "21",
        "label": "Takeo"
      },
      {
        "value": "22",
        "label": "Oddar Meanchey"
      },
      {
        "value": "23",
        "label": "Kep"
      },
      {
        "value": "24",
        "label": "Pailin"
      },
      {
        "value": "25",
        "label": "Tbong Khmum"
      },
      {
        "value": "3",
        "label": "Kampong Cham"
      },
      {
        "value": "4",
        "label": "Kampong Chhnang"
      },
      {
        "value": "5",
        "label": "Kampong Speu"
      },
      {
        "value": "6",
        "label": "Kampong Thom"
      },
      {
        "value": "7",
        "label": "Kampot"
      },
      {
        "value": "8",
        "label": "Kandal"
      },
      {
        "value": "9",
        "label": "Koh Kong"
      }
    ]
  },
  {
    "value": "KI",
    "label": "Kiribati",
    "states": [
      {
        "value": "G",
        "label": "Gilbert Islands"
      },
      {
        "value": "L",
        "label": "Line Islands"
      },
      {
        "value": "P",
        "label": "Phoenix Islands"
      }
    ]
  },
  {
    "value": "KM",
    "label": "Comoros",
    "states": [
      {
        "value": "A",
        "label": "Anjouan"
      },
      {
        "value": "G",
        "label": "Grande Comore"
      },
      {
        "value": "M",
        "label": "Mohéli"
      }
    ]
  },
  {
    "value": "KN",
    "label": "Saint Kitts and Nevis",
    "states": [
      {
        "value": "01",
        "label": "Christ Church Nichola Town"
      },
      {
        "value": "02",
        "label": "Saint Anne Sandy Point"
      },
      {
        "value": "03",
        "label": "Saint George Basseterre"
      },
      {
        "value": "04",
        "label": "Saint George Gingerland"
      },
      {
        "value": "05",
        "label": "Saint James Windward"
      },
      {
        "value": "06",
        "label": "Saint John Capisterre"
      },
      {
        "value": "07",
        "label": "Saint John Figtree"
      },
      {
        "value": "08",
        "label": "Saint Mary Cayon"
      },
      {
        "value": "09",
        "label": "Saint Paul Capisterre"
      },
      {
        "value": "10",
        "label": "Saint Paul Charlestown"
      },
      {
        "value": "11",
        "label": "Saint Peter Basseterre"
      },
      {
        "value": "12",
        "label": "Saint Thomas Lowland"
      },
      {
        "value": "13",
        "label": "Saint Thomas Middle Island"
      },
      {
        "value": "15",
        "label": "Trinity Palmetto Point"
      },
      {
        "value": "K",
        "label": "Saint Kitts"
      },
      {
        "value": "N",
        "label": "Nevis"
      }
    ]
  },
  {
    "value": "KP",
    "label": "Korea, Democratic People's Republic of",
    "states": [
      {
        "value": "01",
        "label": "Phyeongyang"
      },
      {
        "value": "02",
        "label": "Phyeongannamto"
      },
      {
        "value": "03",
        "label": "Phyeonganpukto"
      },
      {
        "value": "04",
        "label": "Jakangto"
      },
      {
        "value": "05",
        "label": "Hwanghainamto"
      },
      {
        "value": "06",
        "label": "Hwanghaipukto"
      },
      {
        "value": "07",
        "label": "Kangweonto"
      },
      {
        "value": "08",
        "label": "Hamkyeongnamto"
      },
      {
        "value": "09",
        "label": "Hamkyeongpukto"
      },
      {
        "value": "10",
        "label": "Ryangkangto"
      },
      {
        "value": "13",
        "label": "Raseon"
      },
      {
        "value": "14",
        "label": "Nampho"
      },
      {
        "value": "15",
        "label": "Kaeseong"
      }
    ]
  },
  {
    "value": "KR",
    "label": "Korea, Republic of",
    "states": [
      {
        "value": "11",
        "label": "Seoul"
      },
      {
        "value": "26",
        "label": "Busan"
      },
      {
        "value": "27",
        "label": "Daegu"
      },
      {
        "value": "28",
        "label": "Incheon"
      },
      {
        "value": "29",
        "label": "Gwangju"
      },
      {
        "value": "30",
        "label": "Daejeon"
      },
      {
        "value": "31",
        "label": "Ulsan"
      },
      {
        "value": "41",
        "label": "Gyeonggi"
      },
      {
        "value": "42",
        "label": "Gangwon"
      },
      {
        "value": "43",
        "label": "Chungbuk"
      },
      {
        "value": "44",
        "label": "Chungnam"
      },
      {
        "value": "45",
        "label": "Jeonbuk"
      },
      {
        "value": "46",
        "label": "Jeonnam"
      },
      {
        "value": "47",
        "label": "Gyeongbuk"
      },
      {
        "value": "48",
        "label": "Gyeongnam"
      },
      {
        "value": "49",
        "label": "Jeju-teukbyeoljachido"
      },
      {
        "value": "50",
        "label": "Sejong"
      }
    ]
  },
  {
    "value": "KW",
    "label": "Kuwait",
    "states": [
      {
        "value": "AH",
        "label": "Al Aḩmadī"
      },
      {
        "value": "FA",
        "label": "Al Farwānīyah"
      },
      {
        "value": "HA",
        "label": "Ḩawallī"
      },
      {
        "value": "JA",
        "label": "Al Jahrā’"
      },
      {
        "value": "KU",
        "label": "Al Kuwayt"
      },
      {
        "value": "MU",
        "label": "Mubārak al Kabīr"
      }
    ]
  },
  {
    "value": "KY",
    "label": "Cayman Islands",
    "states": []
  },
  {
    "value": "KZ",
    "label": "Kazakhstan",
    "states": [
      {
        "value": "10",
        "label": "Abay oblysy"
      },
      {
        "value": "11",
        "label": "Aqmola oblysy"
      },
      {
        "value": "15",
        "label": "Aqtöbe oblysy"
      },
      {
        "value": "19",
        "label": "Almaty oblysy"
      },
      {
        "value": "23",
        "label": "Atyraū oblysy"
      },
      {
        "value": "27",
        "label": "Batys Qazaqstan oblysy"
      },
      {
        "value": "31",
        "label": "Zhambyl oblysy"
      },
      {
        "value": "33",
        "label": "Zhetisū oblysy"
      },
      {
        "value": "35",
        "label": "Qaraghandy oblysy"
      },
      {
        "value": "39",
        "label": "Qostanay oblysy"
      },
      {
        "value": "43",
        "label": "Qyzylorda oblysy"
      },
      {
        "value": "47",
        "label": "Mangghystaū oblysy"
      },
      {
        "value": "55",
        "label": "Pavlodar oblysy"
      },
      {
        "value": "59",
        "label": "Soltüstik Qazaqstan oblysy"
      },
      {
        "value": "61",
        "label": "Türkistan oblysy"
      },
      {
        "value": "62",
        "label": "Ulytaū oblysy"
      },
      {
        "value": "63",
        "label": "Shyghys Qazaqstan oblysy"
      },
      {
        "value": "71",
        "label": "Astana"
      },
      {
        "value": "75",
        "label": "Almaty"
      },
      {
        "value": "79",
        "label": "Shymkent"
      }
    ]
  },
  {
    "value": "LA",
    "label": "Lao People's Democratic Republic",
    "states": [
      {
        "value": "AT",
        "label": "Attapeu"
      },
      {
        "value": "BK",
        "label": "Bokèo"
      },
      {
        "value": "BL",
        "label": "Borikhamxay"
      },
      {
        "value": "CH",
        "label": "Champasack"
      },
      {
        "value": "HO",
        "label": "Huaphanh"
      },
      {
        "value": "KH",
        "label": "Khammuane"
      },
      {
        "value": "LM",
        "label": "Luangnamtha"
      },
      {
        "value": "LP",
        "label": "Luangprabang"
      },
      {
        "value": "OU",
        "label": "Oudomxay"
      },
      {
        "value": "PH",
        "label": "Phongsaly"
      },
      {
        "value": "SL",
        "label": "Saravane"
      },
      {
        "value": "SV",
        "label": "Savannakhet"
      },
      {
        "value": "VT",
        "label": "Vientiane"
      },
      {
        "value": "XA",
        "label": "Xayabury"
      },
      {
        "value": "XE",
        "label": "Sekong"
      },
      {
        "value": "XI",
        "label": "Xiengkhuang"
      },
      {
        "value": "XS",
        "label": "Xaysomboon"
      }
    ]
  },
  {
    "value": "LB",
    "label": "Lebanon",
    "states": [
      {
        "value": "AK",
        "label": "Aakkâr"
      },
      {
        "value": "AS",
        "label": "Liban-Nord"
      },
      {
        "value": "BA",
        "label": "Beyrouth"
      },
      {
        "value": "BH",
        "label": "Baalbek-Hermel"
      },
      {
        "value": "BI",
        "label": "Béqaa"
      },
      {
        "value": "JA",
        "label": "Liban-Sud"
      },
      {
        "value": "JL",
        "label": "Mont-Liban"
      },
      {
        "value": "NA",
        "label": "Nabatîyé"
      }
    ]
  },
  {
    "value": "LC",
    "label": "Saint Lucia",
    "states": [
      {
        "value": "01",
        "label": "Anse la Raye"
      },
      {
        "value": "02",
        "label": "Castries"
      },
      {
        "value": "03",
        "label": "Choiseul"
      },
      {
        "value": "05",
        "label": "Dennery"
      },
      {
        "value": "06",
        "label": "Gros Islet"
      },
      {
        "value": "07",
        "label": "Laborie"
      },
      {
        "value": "08",
        "label": "Micoud"
      },
      {
        "value": "10",
        "label": "Soufrière"
      },
      {
        "value": "11",
        "label": "Vieux Fort"
      },
      {
        "value": "12",
        "label": "Canaries"
      }
    ]
  },
  {
    "value": "LI",
    "label": "Liechtenstein",
    "states": [
      {
        "value": "01",
        "label": "Balzers"
      },
      {
        "value": "02",
        "label": "Eschen"
      },
      {
        "value": "03",
        "label": "Gamprin"
      },
      {
        "value": "04",
        "label": "Mauren"
      },
      {
        "value": "05",
        "label": "Planken"
      },
      {
        "value": "06",
        "label": "Ruggell"
      },
      {
        "value": "07",
        "label": "Schaan"
      },
      {
        "value": "08",
        "label": "Schellenberg"
      },
      {
        "value": "09",
        "label": "Triesen"
      },
      {
        "value": "10",
        "label": "Triesenberg"
      },
      {
        "value": "11",
        "label": "Vaduz"
      }
    ]
  },
  {
    "value": "LK",
    "label": "Sri Lanka",
    "states": [
      {
        "value": "1",
        "label": "Western Province"
      },
      {
        "value": "11",
        "label": "Colombo"
      },
      {
        "value": "12",
        "label": "Gampaha"
      },
      {
        "value": "13",
        "label": "Kalutara"
      },
      {
        "value": "2",
        "label": "Central Province"
      },
      {
        "value": "21",
        "label": "Kandy"
      },
      {
        "value": "22",
        "label": "Matale"
      },
      {
        "value": "23",
        "label": "Nuwara Eliya"
      },
      {
        "value": "3",
        "label": "Southern Province"
      },
      {
        "value": "31",
        "label": "Galle"
      },
      {
        "value": "32",
        "label": "Matara"
      },
      {
        "value": "33",
        "label": "Hambantota"
      },
      {
        "value": "4",
        "label": "Northern Province"
      },
      {
        "value": "41",
        "label": "Jaffna"
      },
      {
        "value": "42",
        "label": "Kilinochchi"
      },
      {
        "value": "43",
        "label": "Mannar"
      },
      {
        "value": "44",
        "label": "Vavuniya"
      },
      {
        "value": "45",
        "label": "Mullaittivu"
      },
      {
        "value": "5",
        "label": "Eastern Province"
      },
      {
        "value": "51",
        "label": "Batticaloa"
      },
      {
        "value": "52",
        "label": "Ampara"
      },
      {
        "value": "53",
        "label": "Trincomalee"
      },
      {
        "value": "6",
        "label": "North Western Province"
      },
      {
        "value": "61",
        "label": "Kurunegala"
      },
      {
        "value": "62",
        "label": "Puttalam"
      },
      {
        "value": "7",
        "label": "North Central Province"
      },
      {
        "value": "71",
        "label": "Anuradhapura"
      },
      {
        "value": "72",
        "label": "Polonnaruwa"
      },
      {
        "value": "8",
        "label": "Uva Province"
      },
      {
        "value": "81",
        "label": "Badulla"
      },
      {
        "value": "82",
        "label": "Monaragala"
      },
      {
        "value": "9",
        "label": "Sabaragamuwa Province"
      },
      {
        "value": "91",
        "label": "Ratnapura"
      },
      {
        "value": "92",
        "label": "Kegalla"
      }
    ]
  },
  {
    "value": "LR",
    "label": "Liberia",
    "states": [
      {
        "value": "BG",
        "label": "Bong"
      },
      {
        "value": "BM",
        "label": "Bomi"
      },
      {
        "value": "CM",
        "label": "Grand Cape Mount"
      },
      {
        "value": "GB",
        "label": "Grand Bassa"
      },
      {
        "value": "GG",
        "label": "Grand Gedeh"
      },
      {
        "value": "GK",
        "label": "Grand Kru"
      },
      {
        "value": "GP",
        "label": "Gbarpolu"
      },
      {
        "value": "LO",
        "label": "Lofa"
      },
      {
        "value": "MG",
        "label": "Margibi"
      },
      {
        "value": "MO",
        "label": "Montserrado"
      },
      {
        "value": "MY",
        "label": "Maryland"
      },
      {
        "value": "NI",
        "label": "Nimba"
      },
      {
        "value": "RG",
        "label": "River Gee"
      },
      {
        "value": "RI",
        "label": "Rivercess"
      },
      {
        "value": "SI",
        "label": "Sinoe"
      }
    ]
  },
  {
    "value": "LS",
    "label": "Lesotho",
    "states": [
      {
        "value": "A",
        "label": "Maseru"
      },
      {
        "value": "B",
        "label": "Butha-Buthe"
      },
      {
        "value": "C",
        "label": "Leribe"
      },
      {
        "value": "D",
        "label": "Berea"
      },
      {
        "value": "E",
        "label": "Mafeteng"
      },
      {
        "value": "F",
        "label": "Mohale's Hoek"
      },
      {
        "value": "G",
        "label": "Quthing"
      },
      {
        "value": "H",
        "label": "Qacha's Nek"
      },
      {
        "value": "J",
        "label": "Mokhotlong"
      },
      {
        "value": "K",
        "label": "Thaba-Tseka"
      }
    ]
  },
  {
    "value": "LT",
    "label": "Lithuania",
    "states": [
      {
        "value": "01",
        "label": "Akmenė"
      },
      {
        "value": "02",
        "label": "Alytaus miestas"
      },
      {
        "value": "03",
        "label": "Alytus"
      },
      {
        "value": "04",
        "label": "Anykščiai"
      },
      {
        "value": "05",
        "label": "Birštonas"
      },
      {
        "value": "06",
        "label": "Biržai"
      },
      {
        "value": "07",
        "label": "Druskininkai"
      },
      {
        "value": "08",
        "label": "Elektrėnai"
      },
      {
        "value": "09",
        "label": "Ignalina"
      },
      {
        "value": "10",
        "label": "Jonava"
      },
      {
        "value": "11",
        "label": "Joniškis"
      },
      {
        "value": "12",
        "label": "Jurbarkas"
      },
      {
        "value": "13",
        "label": "Kaišiadorys"
      },
      {
        "value": "14",
        "label": "Kalvarija"
      },
      {
        "value": "15",
        "label": "Kauno miestas"
      },
      {
        "value": "16",
        "label": "Kaunas"
      },
      {
        "value": "17",
        "label": "Kazlų Rūdos"
      },
      {
        "value": "18",
        "label": "Kėdainiai"
      },
      {
        "value": "19",
        "label": "Kelmė"
      },
      {
        "value": "20",
        "label": "Klaipėdos miestas"
      },
      {
        "value": "21",
        "label": "Klaipėda"
      },
      {
        "value": "22",
        "label": "Kretinga"
      },
      {
        "value": "23",
        "label": "Kupiškis"
      },
      {
        "value": "24",
        "label": "Lazdijai"
      },
      {
        "value": "25",
        "label": "Marijampolė"
      },
      {
        "value": "26",
        "label": "Mažeikiai"
      },
      {
        "value": "27",
        "label": "Molėtai"
      },
      {
        "value": "28",
        "label": "Neringa"
      },
      {
        "value": "29",
        "label": "Pagėgiai"
      },
      {
        "value": "30",
        "label": "Pakruojis"
      },
      {
        "value": "31",
        "label": "Palangos miestas"
      },
      {
        "value": "32",
        "label": "Panevėžio miestas"
      },
      {
        "value": "33",
        "label": "Panevėžys"
      },
      {
        "value": "34",
        "label": "Pasvalys"
      },
      {
        "value": "35",
        "label": "Plungė"
      },
      {
        "value": "36",
        "label": "Prienai"
      },
      {
        "value": "37",
        "label": "Radviliškis"
      },
      {
        "value": "38",
        "label": "Raseiniai"
      },
      {
        "value": "39",
        "label": "Rietavas"
      },
      {
        "value": "40",
        "label": "Rokiškis"
      },
      {
        "value": "41",
        "label": "Šakiai"
      },
      {
        "value": "42",
        "label": "Šalčininkai"
      },
      {
        "value": "43",
        "label": "Šiaulių miestas"
      },
      {
        "value": "44",
        "label": "Šiauliai"
      },
      {
        "value": "45",
        "label": "Šilalė"
      },
      {
        "value": "46",
        "label": "Šilutė"
      },
      {
        "value": "47",
        "label": "Širvintos"
      },
      {
        "value": "48",
        "label": "Skuodas"
      },
      {
        "value": "49",
        "label": "Švenčionys"
      },
      {
        "value": "50",
        "label": "Tauragė"
      },
      {
        "value": "51",
        "label": "Telšiai"
      },
      {
        "value": "52",
        "label": "Trakai"
      },
      {
        "value": "53",
        "label": "Ukmergė"
      },
      {
        "value": "54",
        "label": "Utena"
      },
      {
        "value": "55",
        "label": "Varėna"
      },
      {
        "value": "56",
        "label": "Vilkaviškis"
      },
      {
        "value": "57",
        "label": "Vilniaus miestas"
      },
      {
        "value": "58",
        "label": "Vilnius"
      },
      {
        "value": "59",
        "label": "Visaginas"
      },
      {
        "value": "60",
        "label": "Zarasai"
      },
      {
        "value": "AL",
        "label": "Alytaus apskritis"
      },
      {
        "value": "KL",
        "label": "Klaipėdos apskritis"
      },
      {
        "value": "KU",
        "label": "Kauno apskritis"
      },
      {
        "value": "MR",
        "label": "Marijampolės apskritis"
      },
      {
        "value": "PN",
        "label": "Panevėžio apskritis"
      },
      {
        "value": "SA",
        "label": "Šiaulių apskritis"
      },
      {
        "value": "TA",
        "label": "Tauragės apskritis"
      },
      {
        "value": "TE",
        "label": "Telšių apskritis"
      },
      {
        "value": "UT",
        "label": "Utenos apskritis"
      },
      {
        "value": "VL",
        "label": "Vilniaus apskritis"
      }
    ]
  },
  {
    "value": "LU",
    "label": "Luxembourg",
    "states": [
      {
        "value": "CA",
        "label": "Kapellen"
      },
      {
        "value": "CL",
        "label": "Klierf"
      },
      {
        "value": "DI",
        "label": "Diekrech"
      },
      {
        "value": "EC",
        "label": "Iechternach"
      },
      {
        "value": "ES",
        "label": "Esch-Uelzecht"
      },
      {
        "value": "GR",
        "label": "Gréivemaacher"
      },
      {
        "value": "LU",
        "label": "Lëtzebuerg"
      },
      {
        "value": "ME",
        "label": "Miersch"
      },
      {
        "value": "RD",
        "label": "Réiden-Atert"
      },
      {
        "value": "RM",
        "label": "Réimech"
      },
      {
        "value": "VD",
        "label": "Veianen"
      },
      {
        "value": "WI",
        "label": "Wolz"
      }
    ]
  },
  {
    "value": "LV",
    "label": "Latvia",
    "states": [
      {
        "value": "002",
        "label": "Aizkraukle"
      },
      {
        "value": "007",
        "label": "Alūksne"
      },
      {
        "value": "011",
        "label": "Ādaži"
      },
      {
        "value": "015",
        "label": "Balvi"
      },
      {
        "value": "016",
        "label": "Bauska"
      },
      {
        "value": "022",
        "label": "Cēsis"
      },
      {
        "value": "026",
        "label": "Dobele"
      },
      {
        "value": "033",
        "label": "Gulbene"
      },
      {
        "value": "042",
        "label": "Jēkabpils"
      },
      {
        "value": "047",
        "label": "Krāslava"
      },
      {
        "value": "050",
        "label": "Kuldīga"
      },
      {
        "value": "052",
        "label": "Ķekava"
      },
      {
        "value": "054",
        "label": "Limbaži"
      },
      {
        "value": "056",
        "label": "Līvāni"
      },
      {
        "value": "058",
        "label": "Ludza"
      },
      {
        "value": "059",
        "label": "Madona"
      },
      {
        "value": "062",
        "label": "Mārupe"
      },
      {
        "value": "067",
        "label": "Ogre"
      },
      {
        "value": "068",
        "label": "Olaine"
      },
      {
        "value": "073",
        "label": "Preiļi"
      },
      {
        "value": "080",
        "label": "Ropaži"
      },
      {
        "value": "087",
        "label": "Salaspils"
      },
      {
        "value": "088",
        "label": "Saldus"
      },
      {
        "value": "089",
        "label": "Saulkrasti"
      },
      {
        "value": "091",
        "label": "Sigulda"
      },
      {
        "value": "094",
        "label": "Smiltene"
      },
      {
        "value": "097",
        "label": "Talsi"
      },
      {
        "value": "099",
        "label": "Tukums"
      },
      {
        "value": "101",
        "label": "Valka"
      },
      {
        "value": "102",
        "label": "Varakļāni"
      },
      {
        "value": "111",
        "label": "Augšdaugava"
      },
      {
        "value": "112",
        "label": "Dienvidkurzeme"
      },
      {
        "value": "113",
        "label": "Valmiera"
      },
      {
        "value": "DGV",
        "label": "Daugavpils"
      },
      {
        "value": "JEL",
        "label": "Jelgava"
      },
      {
        "value": "JUR",
        "label": "Jūrmala"
      },
      {
        "value": "LPX",
        "label": "Liepāja"
      },
      {
        "value": "REZ",
        "label": "Rēzekne"
      },
      {
        "value": "RIX",
        "label": "Rīga"
      },
      {
        "value": "VEN",
        "label": "Ventspils"
      }
    ]
  },
  {
    "value": "LY",
    "label": "Libyan Arab Jamahiriya",
    "states": [
      {
        "value": "BA",
        "label": "Banghāzī"
      },
      {
        "value": "BU",
        "label": "Al Buţnān"
      },
      {
        "value": "DR",
        "label": "Darnah"
      },
      {
        "value": "GT",
        "label": "Ghāt"
      },
      {
        "value": "JA",
        "label": "Al Jabal al Akhḑar"
      },
      {
        "value": "JG",
        "label": "Al Jabal al Gharbī"
      },
      {
        "value": "JI",
        "label": "Al Jafārah"
      },
      {
        "value": "JU",
        "label": "Al Jufrah"
      },
      {
        "value": "KF",
        "label": "Al Kufrah"
      },
      {
        "value": "MB",
        "label": "Al Marqab"
      },
      {
        "value": "MI",
        "label": "Mişrātah"
      },
      {
        "value": "MJ",
        "label": "Al Marj"
      },
      {
        "value": "MQ",
        "label": "Murzuq"
      },
      {
        "value": "NL",
        "label": "Nālūt"
      },
      {
        "value": "NQ",
        "label": "An Nuqāţ al Khams"
      },
      {
        "value": "SB",
        "label": "Sabhā"
      },
      {
        "value": "SR",
        "label": "Surt"
      },
      {
        "value": "TB",
        "label": "Ţarābulus"
      },
      {
        "value": "WA",
        "label": "Al Wāḩāt"
      },
      {
        "value": "WD",
        "label": "Wādī al Ḩayāt"
      },
      {
        "value": "WS",
        "label": "Wādī ash Shāţi’"
      },
      {
        "value": "ZA",
        "label": "Az Zāwiyah"
      }
    ]
  },
  {
    "value": "MA",
    "label": "Morocco",
    "states": [
      {
        "value": "01",
        "label": "Tanger-Tétouan-Al Hoceïma"
      },
      {
        "value": "02",
        "label": "L'Oriental"
      },
      {
        "value": "03",
        "label": "Fès-Meknès"
      },
      {
        "value": "04",
        "label": "Rabat-Salé-Kénitra"
      },
      {
        "value": "05",
        "label": "Béni Mellal-Khénifra"
      },
      {
        "value": "06",
        "label": "Casablanca-Settat"
      },
      {
        "value": "07",
        "label": "Marrakech-Safi"
      },
      {
        "value": "08",
        "label": "Drâa-Tafilalet"
      },
      {
        "value": "09",
        "label": "Souss-Massa"
      },
      {
        "value": "10",
        "label": "Guelmim-Oued Noun"
      },
      {
        "value": "11",
        "label": "Laâyoune-Sakia El Hamra"
      },
      {
        "value": "12",
        "label": "Dakhla-Oued Ed-Dahab"
      },
      {
        "value": "AGD",
        "label": "Agadir-Ida-Ou-Tanane"
      },
      {
        "value": "AOU",
        "label": "Aousserd"
      },
      {
        "value": "ASZ",
        "label": "Assa-Zag"
      },
      {
        "value": "AZI",
        "label": "Azilal"
      },
      {
        "value": "BEM",
        "label": "Béni Mellal"
      },
      {
        "value": "BER",
        "label": "Berkane"
      },
      {
        "value": "BES",
        "label": "Benslimane"
      },
      {
        "value": "BOD",
        "label": "Boujdour"
      },
      {
        "value": "BOM",
        "label": "Boulemane"
      },
      {
        "value": "BRR",
        "label": "Berrechid"
      },
      {
        "value": "CAS",
        "label": "Casablanca"
      },
      {
        "value": "CHE",
        "label": "Chefchaouen"
      },
      {
        "value": "CHI",
        "label": "Chichaoua"
      },
      {
        "value": "CHT",
        "label": "Chtouka-Ait Baha"
      },
      {
        "value": "DRI",
        "label": "Driouch"
      },
      {
        "value": "ERR",
        "label": "Errachidia"
      },
      {
        "value": "ESI",
        "label": "Essaouira"
      },
      {
        "value": "ESM",
        "label": "Es-Semara"
      },
      {
        "value": "FAH",
        "label": "Fahs-Anjra"
      },
      {
        "value": "FES",
        "label": "Fès"
      },
      {
        "value": "FIG",
        "label": "Figuig"
      },
      {
        "value": "FQH",
        "label": "Fquih Ben Salah"
      },
      {
        "value": "GUE",
        "label": "Guelmim"
      },
      {
        "value": "GUF",
        "label": "Guercif"
      },
      {
        "value": "HAJ",
        "label": "El Hajeb"
      },
      {
        "value": "HAO",
        "label": "Al Haouz"
      },
      {
        "value": "HOC",
        "label": "Al Hoceïma"
      },
      {
        "value": "IFR",
        "label": "Ifrane"
      },
      {
        "value": "INE",
        "label": "Inezgane-Ait Melloul"
      },
      {
        "value": "JDI",
        "label": "El Jadida"
      },
      {
        "value": "JRA",
        "label": "Jerada"
      },
      {
        "value": "KEN",
        "label": "Kénitra"
      },
      {
        "value": "KES",
        "label": "El Kelâa des Sraghna"
      },
      {
        "value": "KHE",
        "label": "Khémisset"
      },
      {
        "value": "KHN",
        "label": "Khénifra"
      },
      {
        "value": "KHO",
        "label": "Khouribga"
      },
      {
        "value": "LAA",
        "label": "Laâyoune"
      },
      {
        "value": "LAR",
        "label": "Larache"
      },
      {
        "value": "MAR",
        "label": "Marrakech"
      },
      {
        "value": "MDF",
        "label": "M’diq-Fnideq"
      },
      {
        "value": "MED",
        "label": "Médiouna"
      },
      {
        "value": "MEK",
        "label": "Meknès"
      },
      {
        "value": "MID",
        "label": "Midelt"
      },
      {
        "value": "MOH",
        "label": "Mohammadia"
      },
      {
        "value": "MOU",
        "label": "Moulay Yacoub"
      },
      {
        "value": "NAD",
        "label": "Nador"
      },
      {
        "value": "NOU",
        "label": "Nouaceur"
      },
      {
        "value": "OUA",
        "label": "Ouarzazate"
      },
      {
        "value": "OUD",
        "label": "Oued Ed-Dahab"
      },
      {
        "value": "OUJ",
        "label": "Oujda-Angad"
      },
      {
        "value": "OUZ",
        "label": "Ouezzane"
      },
      {
        "value": "RAB",
        "label": "Rabat"
      },
      {
        "value": "REH",
        "label": "Rehamna"
      },
      {
        "value": "SAF",
        "label": "Safi"
      },
      {
        "value": "SAL",
        "label": "Salé"
      },
      {
        "value": "SEF",
        "label": "Sefrou"
      },
      {
        "value": "SET",
        "label": "Settat"
      },
      {
        "value": "SIB",
        "label": "Sidi Bennour"
      },
      {
        "value": "SIF",
        "label": "Sidi Ifni"
      },
      {
        "value": "SIK",
        "label": "Sidi Kacem"
      },
      {
        "value": "SIL",
        "label": "Sidi Slimane"
      },
      {
        "value": "SKH",
        "label": "Skhirate-Témara"
      },
      {
        "value": "TAF",
        "label": "Tarfaya"
      },
      {
        "value": "TAI",
        "label": "Taourirt"
      },
      {
        "value": "TAO",
        "label": "Taounate"
      },
      {
        "value": "TAR",
        "label": "Taroudannt"
      },
      {
        "value": "TAT",
        "label": "Tata"
      },
      {
        "value": "TAZ",
        "label": "Taza"
      },
      {
        "value": "TET",
        "label": "Tétouan"
      },
      {
        "value": "TIN",
        "label": "Tinghir"
      },
      {
        "value": "TIZ",
        "label": "Tiznit"
      },
      {
        "value": "TNG",
        "label": "Tanger-Assilah"
      },
      {
        "value": "TNT",
        "label": "Tan-Tan"
      },
      {
        "value": "YUS",
        "label": "Youssoufia"
      },
      {
        "value": "ZAG",
        "label": "Zagora"
      }
    ]
  },
  {
    "value": "MC",
    "label": "Monaco",
    "states": [
      {
        "value": "CL",
        "label": "La Colle"
      },
      {
        "value": "CO",
        "label": "La Condamine"
      },
      {
        "value": "FO",
        "label": "Fontvieille"
      },
      {
        "value": "GA",
        "label": "La Gare"
      },
      {
        "value": "JE",
        "label": "Jardin Exotique"
      },
      {
        "value": "LA",
        "label": "Larvotto"
      },
      {
        "value": "MA",
        "label": "Malbousquet"
      },
      {
        "value": "MC",
        "label": "Monte-Carlo"
      },
      {
        "value": "MG",
        "label": "Moneghetti"
      },
      {
        "value": "MO",
        "label": "Monaco-Ville"
      },
      {
        "value": "MU",
        "label": "Moulins"
      },
      {
        "value": "PH",
        "label": "Port-Hercule"
      },
      {
        "value": "SD",
        "label": "Sainte-Dévote"
      },
      {
        "value": "SO",
        "label": "La Source"
      },
      {
        "value": "SP",
        "label": "Spélugues"
      },
      {
        "value": "SR",
        "label": "Saint-Roman"
      },
      {
        "value": "VR",
        "label": "Vallon de la Rousse"
      }
    ]
  },
  {
    "value": "MD",
    "label": "Moldova, Republic of",
    "states": [
      {
        "value": "AN",
        "label": "Anenii Noi"
      },
      {
        "value": "BA",
        "label": "Bălți"
      },
      {
        "value": "BD",
        "label": "Bender"
      },
      {
        "value": "BR",
        "label": "Briceni"
      },
      {
        "value": "BS",
        "label": "Basarabeasca"
      },
      {
        "value": "CA",
        "label": "Cahul"
      },
      {
        "value": "CL",
        "label": "Călărași"
      },
      {
        "value": "CM",
        "label": "Cimișlia"
      },
      {
        "value": "CR",
        "label": "Criuleni"
      },
      {
        "value": "CS",
        "label": "Căușeni"
      },
      {
        "value": "CT",
        "label": "Cantemir"
      },
      {
        "value": "CU",
        "label": "Chișinău"
      },
      {
        "value": "DO",
        "label": "Dondușeni"
      },
      {
        "value": "DR",
        "label": "Drochia"
      },
      {
        "value": "DU",
        "label": "Dubăsari"
      },
      {
        "value": "ED",
        "label": "Edineț"
      },
      {
        "value": "FA",
        "label": "Fălești"
      },
      {
        "value": "FL",
        "label": "Florești"
      },
      {
        "value": "GA",
        "label": "Găgăuzia, Unitatea teritorială autonomă"
      },
      {
        "value": "GL",
        "label": "Glodeni"
      },
      {
        "value": "HI",
        "label": "Hîncești"
      },
      {
        "value": "IA",
        "label": "Ialoveni"
      },
      {
        "value": "LE",
        "label": "Leova"
      },
      {
        "value": "NI",
        "label": "Nisporeni"
      },
      {
        "value": "OC",
        "label": "Ocnița"
      },
      {
        "value": "OR",
        "label": "Orhei"
      },
      {
        "value": "RE",
        "label": "Rezina"
      },
      {
        "value": "RI",
        "label": "Rîșcani"
      },
      {
        "value": "SD",
        "label": "Șoldănești"
      },
      {
        "value": "SI",
        "label": "Sîngerei"
      },
      {
        "value": "SN",
        "label": "Stînga Nistrului, unitatea teritorială din"
      },
      {
        "value": "SO",
        "label": "Soroca"
      },
      {
        "value": "ST",
        "label": "Strășeni"
      },
      {
        "value": "SV",
        "label": "Ștefan Vodă"
      },
      {
        "value": "TA",
        "label": "Taraclia"
      },
      {
        "value": "TE",
        "label": "Telenești"
      },
      {
        "value": "UN",
        "label": "Ungheni"
      }
    ]
  },
  {
    "value": "ME",
    "label": "Montenegro",
    "states": [
      {
        "value": "01",
        "label": "Andrijevica"
      },
      {
        "value": "02",
        "label": "Bar"
      },
      {
        "value": "03",
        "label": "Berane"
      },
      {
        "value": "04",
        "label": "Bijelo Polje"
      },
      {
        "value": "05",
        "label": "Budva"
      },
      {
        "value": "06",
        "label": "Cetinje"
      },
      {
        "value": "07",
        "label": "Danilovgrad"
      },
      {
        "value": "08",
        "label": "Herceg-Novi"
      },
      {
        "value": "09",
        "label": "Kolašin"
      },
      {
        "value": "10",
        "label": "Kotor"
      },
      {
        "value": "11",
        "label": "Mojkovac"
      },
      {
        "value": "12",
        "label": "Nikšić"
      },
      {
        "value": "13",
        "label": "Plav"
      },
      {
        "value": "14",
        "label": "Pljevlja"
      },
      {
        "value": "15",
        "label": "Plužine"
      },
      {
        "value": "16",
        "label": "Podgorica"
      },
      {
        "value": "17",
        "label": "Rožaje"
      },
      {
        "value": "18",
        "label": "Šavnik"
      },
      {
        "value": "19",
        "label": "Tivat"
      },
      {
        "value": "20",
        "label": "Ulcinj"
      },
      {
        "value": "21",
        "label": "Žabljak"
      },
      {
        "value": "22",
        "label": "Gusinje"
      },
      {
        "value": "23",
        "label": "Petnjica"
      },
      {
        "value": "24",
        "label": "Tuzi"
      }
    ]
  },
  {
    "value": "MF",
    "label": "Saint Martin (French part)",
    "states": []
  },
  {
    "value": "MG",
    "label": "Madagascar",
    "states": [
      {
        "value": "A",
        "label": "Toamasina"
      },
      {
        "value": "D",
        "label": "Antsiranana"
      },
      {
        "value": "F",
        "label": "Fianarantsoa"
      },
      {
        "value": "M",
        "label": "Mahajanga"
      },
      {
        "value": "T",
        "label": "Antananarivo"
      },
      {
        "value": "U",
        "label": "Toliara"
      }
    ]
  },
  {
    "value": "MK",
    "label": "Macedonia, the former Yugoslav Republic of",
    "states": [
      {
        "value": "101",
        "label": "Veles"
      },
      {
        "value": "102",
        "label": "Gradsko"
      },
      {
        "value": "103",
        "label": "Demir Kapija"
      },
      {
        "value": "104",
        "label": "Kavadarci"
      },
      {
        "value": "105",
        "label": "Lozovo"
      },
      {
        "value": "106",
        "label": "Negotino"
      },
      {
        "value": "107",
        "label": "Rosoman"
      },
      {
        "value": "108",
        "label": "Sveti Nikole"
      },
      {
        "value": "109",
        "label": "Čaška"
      },
      {
        "value": "201",
        "label": "Berovo"
      },
      {
        "value": "202",
        "label": "Vinica"
      },
      {
        "value": "203",
        "label": "Delčevo"
      },
      {
        "value": "204",
        "label": "Zrnovci"
      },
      {
        "value": "205",
        "label": "Karbinci"
      },
      {
        "value": "206",
        "label": "Kočani"
      },
      {
        "value": "207",
        "label": "Makedonska Kamenica"
      },
      {
        "value": "208",
        "label": "Pehčevo"
      },
      {
        "value": "209",
        "label": "Probištip"
      },
      {
        "value": "210",
        "label": "Češinovo-Obleševo"
      },
      {
        "value": "211",
        "label": "Štip"
      },
      {
        "value": "301",
        "label": "Vevčani"
      },
      {
        "value": "303",
        "label": "Debar"
      },
      {
        "value": "304",
        "label": "Debrca"
      },
      {
        "value": "307",
        "label": "Kičevo"
      },
      {
        "value": "308",
        "label": "Makedonski Brod"
      },
      {
        "value": "310",
        "label": "Ohrid"
      },
      {
        "value": "311",
        "label": "Plasnica"
      },
      {
        "value": "312",
        "label": "Struga"
      },
      {
        "value": "313",
        "label": "Centar Župa"
      },
      {
        "value": "401",
        "label": "Bogdanci"
      },
      {
        "value": "402",
        "label": "Bosilovo"
      },
      {
        "value": "403",
        "label": "Valandovo"
      },
      {
        "value": "404",
        "label": "Vasilevo"
      },
      {
        "value": "405",
        "label": "Gevgelija"
      },
      {
        "value": "406",
        "label": "Dojran"
      },
      {
        "value": "407",
        "label": "Konče"
      },
      {
        "value": "408",
        "label": "Novo Selo"
      },
      {
        "value": "409",
        "label": "Radoviš"
      },
      {
        "value": "410",
        "label": "Strumica"
      },
      {
        "value": "501",
        "label": "Bitola"
      },
      {
        "value": "502",
        "label": "Demir Hisar"
      },
      {
        "value": "503",
        "label": "Dolneni"
      },
      {
        "value": "504",
        "label": "Krivogaštani"
      },
      {
        "value": "505",
        "label": "Kruševo"
      },
      {
        "value": "506",
        "label": "Mogila"
      },
      {
        "value": "507",
        "label": "Novaci"
      },
      {
        "value": "508",
        "label": "Prilep"
      },
      {
        "value": "509",
        "label": "Resen"
      },
      {
        "value": "601",
        "label": "Bogovinje"
      },
      {
        "value": "602",
        "label": "Brvenica"
      },
      {
        "value": "603",
        "label": "Vrapčište"
      },
      {
        "value": "604",
        "label": "Gostivar"
      },
      {
        "value": "605",
        "label": "Želino"
      },
      {
        "value": "606",
        "label": "Jegunovce"
      },
      {
        "value": "607",
        "label": "Mavrovo i Rostuše"
      },
      {
        "value": "608",
        "label": "Tearce"
      },
      {
        "value": "609",
        "label": "Tetovo"
      },
      {
        "value": "701",
        "label": "Kratovo"
      },
      {
        "value": "702",
        "label": "Kriva Palanka"
      },
      {
        "value": "703",
        "label": "Kumanovo"
      },
      {
        "value": "704",
        "label": "Lipkovo"
      },
      {
        "value": "705",
        "label": "Rankovce"
      },
      {
        "value": "706",
        "label": "Staro Nagoričane"
      },
      {
        "value": "801",
        "label": "Aerodrom †"
      },
      {
        "value": "802",
        "label": "Aračinovo"
      },
      {
        "value": "803",
        "label": "Butel †"
      },
      {
        "value": "804",
        "label": "Gazi Baba †"
      },
      {
        "value": "805",
        "label": "Gjorče Petrov †"
      },
      {
        "value": "806",
        "label": "Zelenikovo"
      },
      {
        "value": "807",
        "label": "Ilinden"
      },
      {
        "value": "808",
        "label": "Karpoš †"
      },
      {
        "value": "809",
        "label": "Kisela Voda †"
      },
      {
        "value": "810",
        "label": "Petrovec"
      },
      {
        "value": "811",
        "label": "Saraj †"
      },
      {
        "value": "812",
        "label": "Sopište"
      },
      {
        "value": "813",
        "label": "Studeničani"
      },
      {
        "value": "814",
        "label": "Centar †"
      },
      {
        "value": "815",
        "label": "Čair †"
      },
      {
        "value": "816",
        "label": "Čučer-Sandevo"
      },
      {
        "value": "817",
        "label": "Šuto Orizari †"
      }
    ]
  },
  {
    "value": "ML",
    "label": "Mali",
    "states": [
      {
        "value": "1",
        "label": "Kayes"
      },
      {
        "value": "10",
        "label": "Taoudenni"
      },
      {
        "value": "2",
        "label": "Koulikoro"
      },
      {
        "value": "3",
        "label": "Sikasso"
      },
      {
        "value": "4",
        "label": "Ségou"
      },
      {
        "value": "5",
        "label": "Mopti"
      },
      {
        "value": "6",
        "label": "Tombouctou"
      },
      {
        "value": "7",
        "label": "Gao"
      },
      {
        "value": "8",
        "label": "Kidal"
      },
      {
        "value": "9",
        "label": "Ménaka"
      },
      {
        "value": "BKO",
        "label": "Bamako"
      }
    ]
  },
  {
    "value": "MM",
    "label": "Myanmar",
    "states": [
      {
        "value": "01",
        "label": "Sagaing"
      },
      {
        "value": "02",
        "label": "Bago"
      },
      {
        "value": "03",
        "label": "Magway"
      },
      {
        "value": "04",
        "label": "Mandalay"
      },
      {
        "value": "05",
        "label": "Tanintharyi"
      },
      {
        "value": "06",
        "label": "Yangon"
      },
      {
        "value": "07",
        "label": "Ayeyarwady"
      },
      {
        "value": "11",
        "label": "Kachin"
      },
      {
        "value": "12",
        "label": "Kayah"
      },
      {
        "value": "13",
        "label": "Kayin"
      },
      {
        "value": "14",
        "label": "Chin"
      },
      {
        "value": "15",
        "label": "Mon"
      },
      {
        "value": "16",
        "label": "Rakhine"
      },
      {
        "value": "17",
        "label": "Shan"
      },
      {
        "value": "18",
        "label": "Nay Pyi Taw"
      }
    ]
  },
  {
    "value": "MN",
    "label": "Mongolia",
    "states": [
      {
        "value": "035",
        "label": "Orhon"
      },
      {
        "value": "037",
        "label": "Darhan uul"
      },
      {
        "value": "039",
        "label": "Hentiy"
      },
      {
        "value": "041",
        "label": "Hövsgöl"
      },
      {
        "value": "043",
        "label": "Hovd"
      },
      {
        "value": "046",
        "label": "Uvs"
      },
      {
        "value": "047",
        "label": "Töv"
      },
      {
        "value": "049",
        "label": "Selenge"
      },
      {
        "value": "051",
        "label": "Sühbaatar"
      },
      {
        "value": "053",
        "label": "Ömnögovĭ"
      },
      {
        "value": "055",
        "label": "Övörhangay"
      },
      {
        "value": "057",
        "label": "Dzavhan"
      },
      {
        "value": "059",
        "label": "Dundgovĭ"
      },
      {
        "value": "061",
        "label": "Dornod"
      },
      {
        "value": "063",
        "label": "Dornogovĭ"
      },
      {
        "value": "064",
        "label": "Govĭ-Sümber"
      },
      {
        "value": "065",
        "label": "Govĭ-Altay"
      },
      {
        "value": "067",
        "label": "Bulgan"
      },
      {
        "value": "069",
        "label": "Bayanhongor"
      },
      {
        "value": "071",
        "label": "Bayan-Ölgiy"
      },
      {
        "value": "073",
        "label": "Arhangay"
      },
      {
        "value": "1",
        "label": "Ulaanbaatar"
      }
    ]
  },
  {
    "value": "MO",
    "label": "Macao",
    "states": []
  },
  {
    "value": "MQ",
    "label": "Martinique",
    "states": []
  },
  {
    "value": "MR",
    "label": "Mauritania",
    "states": [
      {
        "value": "01",
        "label": "Hodh ech Chargui"
      },
      {
        "value": "02",
        "label": "Hodh el Gharbi"
      },
      {
        "value": "03",
        "label": "Assaba"
      },
      {
        "value": "04",
        "label": "Gorgol"
      },
      {
        "value": "05",
        "label": "Brakna"
      },
      {
        "value": "06",
        "label": "Trarza"
      },
      {
        "value": "07",
        "label": "Adrar"
      },
      {
        "value": "08",
        "label": "Dakhlet Nouâdhibou"
      },
      {
        "value": "09",
        "label": "Tagant"
      },
      {
        "value": "10",
        "label": "Guidimaka"
      },
      {
        "value": "11",
        "label": "Tiris Zemmour"
      },
      {
        "value": "12",
        "label": "Inchiri"
      },
      {
        "value": "13",
        "label": "Nouakchott Ouest"
      },
      {
        "value": "14",
        "label": "Nouakchott Nord"
      },
      {
        "value": "15",
        "label": "Nouakchott Sud"
      }
    ]
  },
  {
    "value": "MS",
    "label": "Montserrat",
    "states": []
  },
  {
    "value": "MT",
    "label": "Malta",
    "states": [
      {
        "value": "01",
        "label": "Attard"
      },
      {
        "value": "02",
        "label": "Balzan"
      },
      {
        "value": "03",
        "label": "Birgu"
      },
      {
        "value": "04",
        "label": "Birkirkara"
      },
      {
        "value": "05",
        "label": "Birżebbuġa"
      },
      {
        "value": "06",
        "label": "Bormla"
      },
      {
        "value": "07",
        "label": "Dingli"
      },
      {
        "value": "08",
        "label": "Fgura"
      },
      {
        "value": "09",
        "label": "Floriana"
      },
      {
        "value": "10",
        "label": "Fontana"
      },
      {
        "value": "11",
        "label": "Gudja"
      },
      {
        "value": "12",
        "label": "Gżira"
      },
      {
        "value": "13",
        "label": "Għajnsielem"
      },
      {
        "value": "14",
        "label": "Għarb"
      },
      {
        "value": "15",
        "label": "Għargħur"
      },
      {
        "value": "16",
        "label": "Għasri"
      },
      {
        "value": "17",
        "label": "Għaxaq"
      },
      {
        "value": "18",
        "label": "Ħamrun"
      },
      {
        "value": "19",
        "label": "Iklin"
      },
      {
        "value": "20",
        "label": "Isla"
      },
      {
        "value": "21",
        "label": "Kalkara"
      },
      {
        "value": "22",
        "label": "Kerċem"
      },
      {
        "value": "23",
        "label": "Kirkop"
      },
      {
        "value": "24",
        "label": "Lija"
      },
      {
        "value": "25",
        "label": "Luqa"
      },
      {
        "value": "26",
        "label": "Marsa"
      },
      {
        "value": "27",
        "label": "Marsaskala"
      },
      {
        "value": "28",
        "label": "Marsaxlokk"
      },
      {
        "value": "29",
        "label": "Mdina"
      },
      {
        "value": "30",
        "label": "Mellieħa"
      },
      {
        "value": "31",
        "label": "Mġarr"
      },
      {
        "value": "32",
        "label": "Mosta"
      },
      {
        "value": "33",
        "label": "Mqabba"
      },
      {
        "value": "34",
        "label": "Msida"
      },
      {
        "value": "35",
        "label": "Mtarfa"
      },
      {
        "value": "36",
        "label": "Munxar"
      },
      {
        "value": "37",
        "label": "Nadur"
      },
      {
        "value": "38",
        "label": "Naxxar"
      },
      {
        "value": "39",
        "label": "Paola"
      },
      {
        "value": "40",
        "label": "Pembroke"
      },
      {
        "value": "41",
        "label": "Pietà"
      },
      {
        "value": "42",
        "label": "Qala"
      },
      {
        "value": "43",
        "label": "Qormi"
      },
      {
        "value": "44",
        "label": "Qrendi"
      },
      {
        "value": "45",
        "label": "Rabat Gozo"
      },
      {
        "value": "46",
        "label": "Rabat Malta"
      },
      {
        "value": "47",
        "label": "Safi"
      },
      {
        "value": "48",
        "label": "Saint Julian's"
      },
      {
        "value": "49",
        "label": "Saint John"
      },
      {
        "value": "50",
        "label": "Saint Lawrence"
      },
      {
        "value": "51",
        "label": "Saint Paul's Bay"
      },
      {
        "value": "52",
        "label": "Sannat"
      },
      {
        "value": "53",
        "label": "Saint Lucia's"
      },
      {
        "value": "54",
        "label": "Santa Venera"
      },
      {
        "value": "55",
        "label": "Siġġiewi"
      },
      {
        "value": "56",
        "label": "Sliema"
      },
      {
        "value": "57",
        "label": "Swieqi"
      },
      {
        "value": "58",
        "label": "Ta' Xbiex"
      },
      {
        "value": "59",
        "label": "Tarxien"
      },
      {
        "value": "60",
        "label": "Valletta"
      },
      {
        "value": "61",
        "label": "Xagħra"
      },
      {
        "value": "62",
        "label": "Xewkija"
      },
      {
        "value": "63",
        "label": "Xgħajra"
      },
      {
        "value": "64",
        "label": "Żabbar"
      },
      {
        "value": "65",
        "label": "Żebbuġ Gozo"
      },
      {
        "value": "66",
        "label": "Żebbuġ Malta"
      },
      {
        "value": "67",
        "label": "Żejtun"
      },
      {
        "value": "68",
        "label": "Żurrieq"
      }
    ]
  },
  {
    "value": "MU",
    "label": "Mauritius",
    "states": [
      {
        "value": "AG",
        "label": "Agalega Islands"
      },
      {
        "value": "BL",
        "label": "Black River"
      },
      {
        "value": "CC",
        "label": "Saint Brandon Islands"
      },
      {
        "value": "FL",
        "label": "Flacq"
      },
      {
        "value": "GP",
        "label": "Grand Port"
      },
      {
        "value": "MO",
        "label": "Moka"
      },
      {
        "value": "PA",
        "label": "Pamplemousses"
      },
      {
        "value": "PL",
        "label": "Port Louis"
      },
      {
        "value": "PW",
        "label": "Plaines Wilhems"
      },
      {
        "value": "RO",
        "label": "Rodrigues Island"
      },
      {
        "value": "RR",
        "label": "Rivière du Rempart"
      },
      {
        "value": "SA",
        "label": "Savanne"
      }
    ]
  },
  {
    "value": "MV",
    "label": "Maldives",
    "states": [
      {
        "value": "00",
        "label": "South Ari Atoll"
      },
      {
        "value": "01",
        "label": "Addu City"
      },
      {
        "value": "02",
        "label": "North Ari Atoll"
      },
      {
        "value": "03",
        "label": "Faadhippolhu"
      },
      {
        "value": "04",
        "label": "Felidhu Atoll"
      },
      {
        "value": "05",
        "label": "Hahdhunmathi"
      },
      {
        "value": "07",
        "label": "North Thiladhunmathi"
      },
      {
        "value": "08",
        "label": "Kolhumadulu"
      },
      {
        "value": "12",
        "label": "Mulaku Atoll"
      },
      {
        "value": "13",
        "label": "North Maalhosmadulu"
      },
      {
        "value": "14",
        "label": "North Nilandhe Atoll"
      },
      {
        "value": "17",
        "label": "South Nilandhe Atoll"
      },
      {
        "value": "20",
        "label": "South Maalhosmadulu"
      },
      {
        "value": "23",
        "label": "South Thiladhunmathi"
      },
      {
        "value": "24",
        "label": "North Miladhunmadulu"
      },
      {
        "value": "25",
        "label": "South Miladhunmadulu"
      },
      {
        "value": "26",
        "label": "Male Atoll"
      },
      {
        "value": "27",
        "label": "North Huvadhu Atoll"
      },
      {
        "value": "28",
        "label": "South Huvadhu Atoll"
      },
      {
        "value": "29",
        "label": "Fuvammulah"
      },
      {
        "value": "MLE",
        "label": "Male"
      }
    ]
  },
  {
    "value": "MW",
    "label": "Malawi",
    "states": [
      {
        "value": "BA",
        "label": "Balaka"
      },
      {
        "value": "BL",
        "label": "Blantyre"
      },
      {
        "value": "C",
        "label": "Central Region"
      },
      {
        "value": "CK",
        "label": "Chikwawa"
      },
      {
        "value": "CR",
        "label": "Chiradzulu"
      },
      {
        "value": "CT",
        "label": "Chitipa"
      },
      {
        "value": "DE",
        "label": "Dedza"
      },
      {
        "value": "DO",
        "label": "Dowa"
      },
      {
        "value": "KR",
        "label": "Karonga"
      },
      {
        "value": "KS",
        "label": "Kasungu"
      },
      {
        "value": "LI",
        "label": "Lilongwe"
      },
      {
        "value": "LK",
        "label": "Likoma"
      },
      {
        "value": "MC",
        "label": "Mchinji"
      },
      {
        "value": "MG",
        "label": "Mangochi"
      },
      {
        "value": "MH",
        "label": "Machinga"
      },
      {
        "value": "MU",
        "label": "Mulanje"
      },
      {
        "value": "MW",
        "label": "Mwanza"
      },
      {
        "value": "MZ",
        "label": "Mzimba"
      },
      {
        "value": "N",
        "label": "Northern Region"
      },
      {
        "value": "NB",
        "label": "Nkhata Bay"
      },
      {
        "value": "NE",
        "label": "Neno"
      },
      {
        "value": "NI",
        "label": "Ntchisi"
      },
      {
        "value": "NK",
        "label": "Nkhotakota"
      },
      {
        "value": "NS",
        "label": "Nsanje"
      },
      {
        "value": "NU",
        "label": "Ntcheu"
      },
      {
        "value": "PH",
        "label": "Phalombe"
      },
      {
        "value": "RU",
        "label": "Rumphi"
      },
      {
        "value": "S",
        "label": "Southern Region"
      },
      {
        "value": "SA",
        "label": "Salima"
      },
      {
        "value": "TH",
        "label": "Thyolo"
      },
      {
        "value": "ZO",
        "label": "Zomba"
      }
    ]
  },
  {
    "value": "MX",
    "label": "Mexico",
    "states": [
      {
        "value": "AG",
        "label": "Aguascalientes"
      },
      {
        "value": "BC",
        "label": "Baja California"
      },
      {
        "value": "BS",
        "label": "Baja California Sur"
      },
      {
        "value": "CH",
        "label": "Chihuahua"
      },
      {
        "value": "CL",
        "label": "Colima"
      },
      {
        "value": "CM",
        "label": "Campeche"
      },
      {
        "value": "CMX",
        "label": "Ciudad de México"
      },
      {
        "value": "CO",
        "label": "Coahuila"
      },
      {
        "value": "CS",
        "label": "Chiapas"
      },
      {
        "value": "DF",
        "label": "Federal District"
      },
      {
        "value": "DG",
        "label": "Durango"
      },
      {
        "value": "GR",
        "label": "Guerrero"
      },
      {
        "value": "GT",
        "label": "Guanajuato"
      },
      {
        "value": "HG",
        "label": "Hidalgo"
      },
      {
        "value": "JA",
        "label": "Jalisco"
      },
      {
        "value": "ME",
        "label": "Mexico State"
      },
      {
        "value": "MEX",
        "label": "México"
      },
      {
        "value": "MI",
        "label": "Michoacán"
      },
      {
        "value": "MO",
        "label": "Morelos"
      },
      {
        "value": "NA",
        "label": "Nayarit"
      },
      {
        "value": "NL",
        "label": "Nuevo León"
      },
      {
        "value": "OA",
        "label": "Oaxaca"
      },
      {
        "value": "PB",
        "label": "Puebla"
      },
      {
        "value": "QE",
        "label": "Querétaro"
      },
      {
        "value": "QR",
        "label": "Quintana Roo"
      },
      {
        "value": "SI",
        "label": "Sinaloa"
      },
      {
        "value": "SL",
        "label": "San Luis Potosí"
      },
      {
        "value": "SO",
        "label": "Sonora"
      },
      {
        "value": "TB",
        "label": "Tabasco"
      },
      {
        "value": "TL",
        "label": "Tlaxcala"
      },
      {
        "value": "TM",
        "label": "Tamaulipas"
      },
      {
        "value": "VE",
        "label": "Veracruz"
      },
      {
        "value": "YU",
        "label": "Yucatán"
      },
      {
        "value": "ZA",
        "label": "Zacatecas"
      }
    ]
  },
  {
    "value": "MY",
    "label": "Malaysia",
    "states": [
      {
        "value": "01",
        "label": "Johor"
      },
      {
        "value": "02",
        "label": "Kedah"
      },
      {
        "value": "03",
        "label": "Kelantan"
      },
      {
        "value": "04",
        "label": "Melaka"
      },
      {
        "value": "05",
        "label": "Negeri Sembilan"
      },
      {
        "value": "06",
        "label": "Pahang"
      },
      {
        "value": "07",
        "label": "Pulau Pinang"
      },
      {
        "value": "08",
        "label": "Perak"
      },
      {
        "value": "09",
        "label": "Perlis"
      },
      {
        "value": "10",
        "label": "Selangor"
      },
      {
        "value": "11",
        "label": "Terengganu"
      },
      {
        "value": "12",
        "label": "Sabah"
      },
      {
        "value": "13",
        "label": "Sarawak"
      },
      {
        "value": "14",
        "label": "Wilayah Persekutuan Kuala Lumpur"
      },
      {
        "value": "15",
        "label": "Wilayah Persekutuan Labuan"
      },
      {
        "value": "16",
        "label": "Wilayah Persekutuan Putrajaya"
      }
    ]
  },
  {
    "value": "MZ",
    "label": "Mozambique",
    "states": [
      {
        "value": "A",
        "label": "Niassa"
      },
      {
        "value": "B",
        "label": "Manica"
      },
      {
        "value": "G",
        "label": "Gaza"
      },
      {
        "value": "I",
        "label": "Inhambane"
      },
      {
        "value": "MPM",
        "label": "Maputo"
      },
      {
        "value": "N",
        "label": "Nampula"
      },
      {
        "value": "P",
        "label": "Cabo Delgado"
      },
      {
        "value": "Q",
        "label": "Zambézia"
      },
      {
        "value": "S",
        "label": "Sofala"
      },
      {
        "value": "T",
        "label": "Tete"
      }
    ]
  },
  {
    "value": "NA",
    "label": "Namibia",
    "states": [
      {
        "value": "CA",
        "label": "Zambezi"
      },
      {
        "value": "ER",
        "label": "Erongo"
      },
      {
        "value": "HA",
        "label": "Hardap"
      },
      {
        "value": "KA",
        "label": "Karas"
      },
      {
        "value": "KE",
        "label": "Kavango East"
      },
      {
        "value": "KH",
        "label": "Khomas"
      },
      {
        "value": "KU",
        "label": "Kunene"
      },
      {
        "value": "KW",
        "label": "Kavango West"
      },
      {
        "value": "OD",
        "label": "Otjozondjupa"
      },
      {
        "value": "OH",
        "label": "Omaheke"
      },
      {
        "value": "ON",
        "label": "Oshana"
      },
      {
        "value": "OS",
        "label": "Omusati"
      },
      {
        "value": "OT",
        "label": "Oshikoto"
      },
      {
        "value": "OW",
        "label": "Ohangwena"
      }
    ]
  },
  {
    "value": "NC",
    "label": "New Caledonia",
    "states": []
  },
  {
    "value": "NE",
    "label": "Niger",
    "states": [
      {
        "value": "1",
        "label": "Agadez"
      },
      {
        "value": "2",
        "label": "Diffa"
      },
      {
        "value": "3",
        "label": "Dosso"
      },
      {
        "value": "4",
        "label": "Maradi"
      },
      {
        "value": "5",
        "label": "Tahoua"
      },
      {
        "value": "6",
        "label": "Tillabéri"
      },
      {
        "value": "7",
        "label": "Zinder"
      },
      {
        "value": "8",
        "label": "Niamey"
      }
    ]
  },
  {
    "value": "NF",
    "label": "Norfolk Island",
    "states": []
  },
  {
    "value": "NG",
    "label": "Nigeria",
    "states": [
      {
        "value": "AB",
        "label": "Abia"
      },
      {
        "value": "AD",
        "label": "Adamawa"
      },
      {
        "value": "AK",
        "label": "Akwa Ibom"
      },
      {
        "value": "AN",
        "label": "Anambra"
      },
      {
        "value": "BA",
        "label": "Bauchi"
      },
      {
        "value": "BE",
        "label": "Benue"
      },
      {
        "value": "BO",
        "label": "Borno"
      },
      {
        "value": "BY",
        "label": "Bayelsa"
      },
      {
        "value": "CR",
        "label": "Cross River"
      },
      {
        "value": "DE",
        "label": "Delta"
      },
      {
        "value": "EB",
        "label": "Ebonyi"
      },
      {
        "value": "ED",
        "label": "Edo"
      },
      {
        "value": "EK",
        "label": "Ekiti"
      },
      {
        "value": "EN",
        "label": "Enugu"
      },
      {
        "value": "FC",
        "label": "Abuja Federal Capital Territory"
      },
      {
        "value": "GO",
        "label": "Gombe"
      },
      {
        "value": "IM",
        "label": "Imo"
      },
      {
        "value": "JI",
        "label": "Jigawa"
      },
      {
        "value": "KD",
        "label": "Kaduna"
      },
      {
        "value": "KE",
        "label": "Kebbi"
      },
      {
        "value": "KN",
        "label": "Kano"
      },
      {
        "value": "KO",
        "label": "Kogi"
      },
      {
        "value": "KT",
        "label": "Katsina"
      },
      {
        "value": "KW",
        "label": "Kwara"
      },
      {
        "value": "LA",
        "label": "Lagos"
      },
      {
        "value": "NA",
        "label": "Nasarawa"
      },
      {
        "value": "NI",
        "label": "Niger"
      },
      {
        "value": "OG",
        "label": "Ogun"
      },
      {
        "value": "ON",
        "label": "Ondo"
      },
      {
        "value": "OS",
        "label": "Osun"
      },
      {
        "value": "OY",
        "label": "Oyo"
      },
      {
        "value": "PL",
        "label": "Plateau"
      },
      {
        "value": "RI",
        "label": "Rivers"
      },
      {
        "value": "SO",
        "label": "Sokoto"
      },
      {
        "value": "TA",
        "label": "Taraba"
      },
      {
        "value": "YO",
        "label": "Yobe"
      },
      {
        "value": "ZA",
        "label": "Zamfara"
      }
    ]
  },
  {
    "value": "NI",
    "label": "Nicaragua",
    "states": [
      {
        "value": "AN",
        "label": "Costa Caribe Norte"
      },
      {
        "value": "AS",
        "label": "Costa Caribe Sur"
      },
      {
        "value": "BO",
        "label": "Boaco"
      },
      {
        "value": "CA",
        "label": "Carazo"
      },
      {
        "value": "CI",
        "label": "Chinandega"
      },
      {
        "value": "CO",
        "label": "Chontales"
      },
      {
        "value": "ES",
        "label": "Estelí"
      },
      {
        "value": "GR",
        "label": "Granada"
      },
      {
        "value": "JI",
        "label": "Jinotega"
      },
      {
        "value": "LE",
        "label": "León"
      },
      {
        "value": "MD",
        "label": "Madriz"
      },
      {
        "value": "MN",
        "label": "Managua"
      },
      {
        "value": "MS",
        "label": "Masaya"
      },
      {
        "value": "MT",
        "label": "Matagalpa"
      },
      {
        "value": "NS",
        "label": "Nueva Segovia"
      },
      {
        "value": "RI",
        "label": "Rivas"
      },
      {
        "value": "SJ",
        "label": "Río San Juan"
      }
    ]
  },
  {
    "value": "NL",
    "label": "Netherlands",
    "states": [
      {
        "value": "AW",
        "label": "Aruba"
      },
      {
        "value": "BQ1",
        "label": "Bonaire"
      },
      {
        "value": "BQ2",
        "label": "Saba"
      },
      {
        "value": "BQ3",
        "label": "Sint Eustatius"
      },
      {
        "value": "CW",
        "label": "Curaçao"
      },
      {
        "value": "DR",
        "label": "Drenthe"
      },
      {
        "value": "FL",
        "label": "Flevoland"
      },
      {
        "value": "FR",
        "label": "Fryslân"
      },
      {
        "value": "GE",
        "label": "Gelderland"
      },
      {
        "value": "GR",
        "label": "Groningen"
      },
      {
        "value": "LI",
        "label": "Limburg"
      },
      {
        "value": "NB",
        "label": "Noord-Brabant"
      },
      {
        "value": "NH",
        "label": "Noord-Holland"
      },
      {
        "value": "OV",
        "label": "Overijssel"
      },
      {
        "value": "SX",
        "label": "Sint Maarten"
      },
      {
        "value": "UT",
        "label": "Utrecht"
      },
      {
        "value": "ZE",
        "label": "Zeeland"
      },
      {
        "value": "ZH",
        "label": "Zuid-Holland"
      }
    ]
  },
  {
    "value": "NO",
    "label": "Norway",
    "states": [
      {
        "value": "03",
        "label": "Oslo"
      },
      {
        "value": "11",
        "label": "Rogaland"
      },
      {
        "value": "15",
        "label": "Møre og Romsdal"
      },
      {
        "value": "18",
        "label": "Nordland"
      },
      {
        "value": "21",
        "label": "Svalbard"
      },
      {
        "value": "22",
        "label": "Jan Mayen"
      },
      {
        "value": "30",
        "label": "Viken"
      },
      {
        "value": "34",
        "label": "Innlandet"
      },
      {
        "value": "38",
        "label": "Vestfold og Telemark"
      },
      {
        "value": "42",
        "label": "Agder"
      },
      {
        "value": "46",
        "label": "Vestland"
      },
      {
        "value": "50",
        "label": "Trøndelag"
      },
      {
        "value": "54",
        "label": "Troms og Finnmark"
      }
    ]
  },
  {
    "value": "NP",
    "label": "Nepal",
    "states": [
      {
        "value": "P1",
        "label": "Pradesh 1 (Province 1)"
      },
      {
        "value": "P2",
        "label": "Madhesh (Province 2)"
      },
      {
        "value": "P3",
        "label": "Bagmati (Province 3)"
      },
      {
        "value": "P4",
        "label": "Gandaki (Province 4)"
      },
      {
        "value": "P5",
        "label": "Lumbini (Province 5)"
      },
      {
        "value": "P6",
        "label": "Karnali (Province 6)"
      },
      {
        "value": "P7",
        "label": "Sudurpashchim (Province 7)"
      }
    ]
  },
  {
    "value": "NR",
    "label": "Nauru",
    "states": [
      {
        "value": "01",
        "label": "Aiwo"
      },
      {
        "value": "02",
        "label": "Anabar"
      },
      {
        "value": "03",
        "label": "Anetan"
      },
      {
        "value": "04",
        "label": "Anibare"
      },
      {
        "value": "05",
        "label": "Baiti"
      },
      {
        "value": "06",
        "label": "Boe"
      },
      {
        "value": "07",
        "label": "Buada"
      },
      {
        "value": "08",
        "label": "Denigomodu"
      },
      {
        "value": "09",
        "label": "Ewa"
      },
      {
        "value": "10",
        "label": "Ijuw"
      },
      {
        "value": "11",
        "label": "Meneng"
      },
      {
        "value": "12",
        "label": "Nibok"
      },
      {
        "value": "13",
        "label": "Uaboe"
      },
      {
        "value": "14",
        "label": "Yaren"
      }
    ]
  },
  {
    "value": "NU",
    "label": "Niue",
    "states": []
  },
  {
    "value": "NZ",
    "label": "New Zealand",
    "states": [
      {
        "value": "AUK",
        "label": "Auckland"
      },
      {
        "value": "BOP",
        "label": "Bay of Plenty"
      },
      {
        "value": "CAN",
        "label": "Canterbury"
      },
      {
        "value": "CIT",
        "label": "Chatham Islands Territory"
      },
      {
        "value": "GIS",
        "label": "Gisborne"
      },
      {
        "value": "HKB",
        "label": "Hawke's Bay"
      },
      {
        "value": "MBH",
        "label": "Marlborough"
      },
      {
        "value": "MWT",
        "label": "Manawatū-Whanganui"
      },
      {
        "value": "NSN",
        "label": "Nelson"
      },
      {
        "value": "NTL",
        "label": "Northland"
      },
      {
        "value": "OTA",
        "label": "Otago"
      },
      {
        "value": "STL",
        "label": "Southland"
      },
      {
        "value": "TAS",
        "label": "Tasman"
      },
      {
        "value": "TKI",
        "label": "Taranaki"
      },
      {
        "value": "WGN",
        "label": "Greater Wellington"
      },
      {
        "value": "WKO",
        "label": "Waikato"
      },
      {
        "value": "WTC",
        "label": "West Coast"
      }
    ]
  },
  {
    "value": "OM",
    "label": "Oman",
    "states": [
      {
        "value": "BJ",
        "label": "Janūb al Bāţinah"
      },
      {
        "value": "BS",
        "label": "Shamāl al Bāţinah"
      },
      {
        "value": "BU",
        "label": "Al Buraymī"
      },
      {
        "value": "DA",
        "label": "Ad Dākhilīyah"
      },
      {
        "value": "MA",
        "label": "Muscat"
      },
      {
        "value": "MU",
        "label": "Musandam"
      },
      {
        "value": "SJ",
        "label": "Janūb ash Sharqīyah"
      },
      {
        "value": "SS",
        "label": "Shamāl ash Sharqīyah"
      },
      {
        "value": "WU",
        "label": "Al Wusţá"
      },
      {
        "value": "ZA",
        "label": "Az̧ Z̧āhirah"
      },
      {
        "value": "ZU",
        "label": "Dhofar"
      }
    ]
  },
  {
    "value": "PA",
    "label": "Panama",
    "states": [
      {
        "value": "1",
        "label": "Bocas del Toro"
      },
      {
        "value": "10",
        "label": "Panamá Oeste"
      },
      {
        "value": "2",
        "label": "Coclé"
      },
      {
        "value": "3",
        "label": "Colón"
      },
      {
        "value": "4",
        "label": "Chiriquí"
      },
      {
        "value": "5",
        "label": "Darién"
      },
      {
        "value": "6",
        "label": "Herrera"
      },
      {
        "value": "7",
        "label": "Los Santos"
      },
      {
        "value": "8",
        "label": "Panamá"
      },
      {
        "value": "9",
        "label": "Veraguas"
      },
      {
        "value": "EM",
        "label": "Emberá"
      },
      {
        "value": "KY",
        "label": "Kuna Yala"
      },
      {
        "value": "NB",
        "label": "Ngäbe-Buglé"
      },
      {
        "value": "NT",
        "label": "Naso Tjër Di"
      }
    ]
  },
  {
    "value": "PE",
    "label": "Peru",
    "states": [
      {
        "value": "AMA",
        "label": "Amazonas"
      },
      {
        "value": "ANC",
        "label": "Ancash"
      },
      {
        "value": "APU",
        "label": "Apurímac"
      },
      {
        "value": "ARE",
        "label": "Arequipa"
      },
      {
        "value": "AYA",
        "label": "Ayacucho"
      },
      {
        "value": "CAJ",
        "label": "Cajamarca"
      },
      {
        "value": "CAL",
        "label": "El Callao"
      },
      {
        "value": "CUS",
        "label": "Cuzco"
      },
      {
        "value": "HUC",
        "label": "Huánuco"
      },
      {
        "value": "HUV",
        "label": "Huancavelica"
      },
      {
        "value": "ICA",
        "label": "Ica"
      },
      {
        "value": "JUN",
        "label": "Junín"
      },
      {
        "value": "LAL",
        "label": "La Libertad"
      },
      {
        "value": "LAM",
        "label": "Lambayeque"
      },
      {
        "value": "LIM",
        "label": "Lima"
      },
      {
        "value": "LMA",
        "label": "Municipalidad Metropolitana de Lima"
      },
      {
        "value": "LOR",
        "label": "Loreto"
      },
      {
        "value": "MDD",
        "label": "Madre de Dios"
      },
      {
        "value": "MOQ",
        "label": "Moquegua"
      },
      {
        "value": "PAS",
        "label": "Pasco"
      },
      {
        "value": "PIU",
        "label": "Piura"
      },
      {
        "value": "PUN",
        "label": "Puno"
      },
      {
        "value": "SAM",
        "label": "San Martín"
      },
      {
        "value": "TAC",
        "label": "Tacna"
      },
      {
        "value": "TUM",
        "label": "Tumbes"
      },
      {
        "value": "UCA",
        "label": "Ucayali"
      }
    ]
  },
  {
    "value": "PF",
    "label": "French Polynesia",
    "states": []
  },
  {
    "value": "PG",
    "label": "Papua New Guinea",
    "states": [
      {
        "value": "CPK",
        "label": "Chimbu"
      },
      {
        "value": "CPM",
        "label": "Central"
      },
      {
        "value": "EBR",
        "label": "East New Britain"
      },
      {
        "value": "EHG",
        "label": "Eastern Highlands"
      },
      {
        "value": "EPW",
        "label": "Enga"
      },
      {
        "value": "ESW",
        "label": "East Sepik"
      },
      {
        "value": "GPK",
        "label": "Gulf"
      },
      {
        "value": "HLA",
        "label": "Hela"
      },
      {
        "value": "JWK",
        "label": "Jiwaka"
      },
      {
        "value": "MBA",
        "label": "Milne Bay"
      },
      {
        "value": "MPL",
        "label": "Morobe"
      },
      {
        "value": "MPM",
        "label": "Madang"
      },
      {
        "value": "MRL",
        "label": "Manus"
      },
      {
        "value": "NCD",
        "label": "National Capital District (Port Moresby)"
      },
      {
        "value": "NIK",
        "label": "New Ireland"
      },
      {
        "value": "NPP",
        "label": "Northern"
      },
      {
        "value": "NSB",
        "label": "Bougainville"
      },
      {
        "value": "SAN",
        "label": "West Sepik"
      },
      {
        "value": "SHM",
        "label": "Southern Highlands"
      },
      {
        "value": "WBK",
        "label": "West New Britain"
      },
      {
        "value": "WHM",
        "label": "Western Highlands"
      },
      {
        "value": "WPD",
        "label": "Western"
      }
    ]
  },
  {
    "value": "PH",
    "label": "Philippines",
    "states": [
      {
        "value": "00",
        "label": "National Capital Region"
      },
      {
        "value": "01",
        "label": "Ilocos (Region I)"
      },
      {
        "value": "02",
        "label": "Cagayan Valley (Region II)"
      },
      {
        "value": "03",
        "label": "Central Luzon (Region III)"
      },
      {
        "value": "05",
        "label": "Bicol (Region V)"
      },
      {
        "value": "06",
        "label": "Western Visayas (Region VI)"
      },
      {
        "value": "07",
        "label": "Central Visayas (Region VII)"
      },
      {
        "value": "08",
        "label": "Eastern Visayas (Region VIII)"
      },
      {
        "value": "09",
        "label": "Zamboanga Peninsula (Region IX)"
      },
      {
        "value": "10",
        "label": "Northern Mindanao (Region X)"
      },
      {
        "value": "11",
        "label": "Davao (Region XI)"
      },
      {
        "value": "12",
        "label": "Soccsksargen (Region XII)"
      },
      {
        "value": "13",
        "label": "Caraga (Region XIII)"
      },
      {
        "value": "14",
        "label": "Autonomous Region in Muslim Mindanao (ARMM)"
      },
      {
        "value": "15",
        "label": "Cordillera Administrative Region (CAR)"
      },
      {
        "value": "40",
        "label": "Calabarzon (Region IV-A)"
      },
      {
        "value": "41",
        "label": "Mimaropa (Region IV-B)"
      },
      {
        "value": "ABR",
        "label": "Abra"
      },
      {
        "value": "AGN",
        "label": "Agusan del Norte"
      },
      {
        "value": "AGS",
        "label": "Agusan del Sur"
      },
      {
        "value": "AKL",
        "label": "Aklan"
      },
      {
        "value": "ALB",
        "label": "Albay"
      },
      {
        "value": "ANT",
        "label": "Antique"
      },
      {
        "value": "APA",
        "label": "Apayao"
      },
      {
        "value": "AUR",
        "label": "Aurora"
      },
      {
        "value": "BAN",
        "label": "Bataan"
      },
      {
        "value": "BAS",
        "label": "Basilan"
      },
      {
        "value": "BEN",
        "label": "Benguet"
      },
      {
        "value": "BIL",
        "label": "Biliran"
      },
      {
        "value": "BOH",
        "label": "Bohol"
      },
      {
        "value": "BTG",
        "label": "Batangas"
      },
      {
        "value": "BTN",
        "label": "Batanes"
      },
      {
        "value": "BUK",
        "label": "Bukidnon"
      },
      {
        "value": "BUL",
        "label": "Bulacan"
      },
      {
        "value": "CAG",
        "label": "Cagayan"
      },
      {
        "value": "CAM",
        "label": "Camiguin"
      },
      {
        "value": "CAN",
        "label": "Camarines Norte"
      },
      {
        "value": "CAP",
        "label": "Capiz"
      },
      {
        "value": "CAS",
        "label": "Camarines Sur"
      },
      {
        "value": "CAT",
        "label": "Catanduanes"
      },
      {
        "value": "CAV",
        "label": "Cavite"
      },
      {
        "value": "CEB",
        "label": "Cebu"
      },
      {
        "value": "COM",
        "label": "Davao de Oro"
      },
      {
        "value": "DAO",
        "label": "Davao Oriental"
      },
      {
        "value": "DAS",
        "label": "Davao del Sur"
      },
      {
        "value": "DAV",
        "label": "Davao del Norte"
      },
      {
        "value": "DIN",
        "label": "Dinagat Islands"
      },
      {
        "value": "DVO",
        "label": "Davao Occidental"
      },
      {
        "value": "EAS",
        "label": "Eastern Samar"
      },
      {
        "value": "GUI",
        "label": "Guimaras"
      },
      {
        "value": "IFU",
        "label": "Ifugao"
      },
      {
        "value": "ILI",
        "label": "Iloilo"
      },
      {
        "value": "ILN",
        "label": "Ilocos Norte"
      },
      {
        "value": "ILS",
        "label": "Ilocos Sur"
      },
      {
        "value": "ISA",
        "label": "Isabela"
      },
      {
        "value": "KAL",
        "label": "Kalinga"
      },
      {
        "value": "LAG",
        "label": "Laguna"
      },
      {
        "value": "LAN",
        "label": "Lanao del Norte"
      },
      {
        "value": "LAS",
        "label": "Lanao del Sur"
      },
      {
        "value": "LEY",
        "label": "Leyte"
      },
      {
        "value": "LUN",
        "label": "La Union"
      },
      {
        "value": "MAD",
        "label": "Marinduque"
      },
      {
        "value": "MAG",
        "label": "Maguindanao"
      },
      {
        "value": "MAS",
        "label": "Masbate"
      },
      {
        "value": "MDC",
        "label": "Mindoro Occidental"
      },
      {
        "value": "MDR",
        "label": "Mindoro Oriental"
      },
      {
        "value": "MOU",
        "label": "Mountain Province"
      },
      {
        "value": "MSC",
        "label": "Misamis Occidental"
      },
      {
        "value": "MSR",
        "label": "Misamis Oriental"
      },
      {
        "value": "NCO",
        "label": "Cotabato"
      },
      {
        "value": "NEC",
        "label": "Negros Occidental"
      },
      {
        "value": "NER",
        "label": "Negros Oriental"
      },
      {
        "value": "NSA",
        "label": "Northern Samar"
      },
      {
        "value": "NUE",
        "label": "Nueva Ecija"
      },
      {
        "value": "NUV",
        "label": "Nueva Vizcaya"
      },
      {
        "value": "PAM",
        "label": "Pampanga"
      },
      {
        "value": "PAN",
        "label": "Pangasinan"
      },
      {
        "value": "PLW",
        "label": "Palawan"
      },
      {
        "value": "QUE",
        "label": "Quezon"
      },
      {
        "value": "QUI",
        "label": "Quirino"
      },
      {
        "value": "RIZ",
        "label": "Rizal"
      },
      {
        "value": "ROM",
        "label": "Romblon"
      },
      {
        "value": "SAR",
        "label": "Sarangani"
      },
      {
        "value": "SCO",
        "label": "South Cotabato"
      },
      {
        "value": "SIG",
        "label": "Siquijor"
      },
      {
        "value": "SLE",
        "label": "Southern Leyte"
      },
      {
        "value": "SLU",
        "label": "Sulu"
      },
      {
        "value": "SOR",
        "label": "Sorsogon"
      },
      {
        "value": "SUK",
        "label": "Sultan Kudarat"
      },
      {
        "value": "SUN",
        "label": "Surigao del Norte"
      },
      {
        "value": "SUR",
        "label": "Surigao del Sur"
      },
      {
        "value": "TAR",
        "label": "Tarlac"
      },
      {
        "value": "TAW",
        "label": "Tawi-Tawi"
      },
      {
        "value": "WSA",
        "label": "Western Samar"
      },
      {
        "value": "ZAN",
        "label": "Zamboanga del Norte"
      },
      {
        "value": "ZAS",
        "label": "Zamboanga del Sur"
      },
      {
        "value": "ZMB",
        "label": "Zambales"
      },
      {
        "value": "ZSI",
        "label": "Zamboanga Sibugay"
      }
    ]
  },
  {
    "value": "PK",
    "label": "Pakistan",
    "states": [
      {
        "value": "BA",
        "label": "Balochistan"
      },
      {
        "value": "GB",
        "label": "Gilgit-Baltistan"
      },
      {
        "value": "IS",
        "label": "Islamabad"
      },
      {
        "value": "JK",
        "label": "Azad Jammu and Kashmir"
      },
      {
        "value": "KP",
        "label": "Khyber Pakhtunkhwa"
      },
      {
        "value": "PB",
        "label": "Punjab"
      },
      {
        "value": "SD",
        "label": "Sindh"
      }
    ]
  },
  {
    "value": "PL",
    "label": "Poland",
    "states": [
      {
        "value": "02",
        "label": "Dolnośląskie"
      },
      {
        "value": "04",
        "label": "Kujawsko-pomorskie"
      },
      {
        "value": "06",
        "label": "Lubelskie"
      },
      {
        "value": "08",
        "label": "Lubuskie"
      },
      {
        "value": "10",
        "label": "Łódzkie"
      },
      {
        "value": "12",
        "label": "Małopolskie"
      },
      {
        "value": "14",
        "label": "Mazowieckie"
      },
      {
        "value": "16",
        "label": "Opolskie"
      },
      {
        "value": "18",
        "label": "Podkarpackie"
      },
      {
        "value": "20",
        "label": "Podlaskie"
      },
      {
        "value": "22",
        "label": "Pomorskie"
      },
      {
        "value": "24",
        "label": "Śląskie"
      },
      {
        "value": "26",
        "label": "Świętokrzyskie"
      },
      {
        "value": "28",
        "label": "Warmińsko-mazurskie"
      },
      {
        "value": "30",
        "label": "Wielkopolskie"
      },
      {
        "value": "32",
        "label": "Zachodniopomorskie"
      }
    ]
  },
  {
    "value": "PM",
    "label": "Saint Pierre and Miquelon",
    "states": []
  },
  {
    "value": "PN",
    "label": "Pitcairn",
    "states": []
  },
  {
    "value": "PS",
    "label": "Palestinian Territory, Occupied",
    "states": [
      {
        "value": "BTH",
        "label": "Bethlehem"
      },
      {
        "value": "DEB",
        "label": "Deir El Balah"
      },
      {
        "value": "GZA",
        "label": "Gaza"
      },
      {
        "value": "HBN",
        "label": "Hebron"
      },
      {
        "value": "JEM",
        "label": "Jerusalem"
      },
      {
        "value": "JEN",
        "label": "Jenin"
      },
      {
        "value": "JRH",
        "label": "Jericho and Al Aghwar"
      },
      {
        "value": "KYS",
        "label": "Khan Yunis"
      },
      {
        "value": "NBS",
        "label": "Nablus"
      },
      {
        "value": "NGZ",
        "label": "North Gaza"
      },
      {
        "value": "QQA",
        "label": "Qalqilya"
      },
      {
        "value": "RBH",
        "label": "Ramallah"
      },
      {
        "value": "RFH",
        "label": "Rafah"
      },
      {
        "value": "SLT",
        "label": "Salfit"
      },
      {
        "value": "TBS",
        "label": "Tubas"
      },
      {
        "value": "TKM",
        "label": "Tulkarm"
      }
    ]
  },
  {
    "value": "PT",
    "label": "Portugal",
    "states": [
      {
        "value": "01",
        "label": "Aveiro"
      },
      {
        "value": "02",
        "label": "Beja"
      },
      {
        "value": "03",
        "label": "Braga"
      },
      {
        "value": "04",
        "label": "Bragança"
      },
      {
        "value": "05",
        "label": "Castelo Branco"
      },
      {
        "value": "06",
        "label": "Coimbra"
      },
      {
        "value": "07",
        "label": "Évora"
      },
      {
        "value": "08",
        "label": "Faro"
      },
      {
        "value": "09",
        "label": "Guarda"
      },
      {
        "value": "10",
        "label": "Leiria"
      },
      {
        "value": "11",
        "label": "Lisboa"
      },
      {
        "value": "12",
        "label": "Portalegre"
      },
      {
        "value": "13",
        "label": "Porto"
      },
      {
        "value": "14",
        "label": "Santarém"
      },
      {
        "value": "15",
        "label": "Setúbal"
      },
      {
        "value": "16",
        "label": "Viana do Castelo"
      },
      {
        "value": "17",
        "label": "Vila Real"
      },
      {
        "value": "18",
        "label": "Viseu"
      },
      {
        "value": "20",
        "label": "Região Autónoma dos Açores"
      },
      {
        "value": "30",
        "label": "Região Autónoma da Madeira"
      }
    ]
  },
  {
    "value": "PY",
    "label": "Paraguay",
    "states": [
      {
        "value": "1",
        "label": "Concepción"
      },
      {
        "value": "10",
        "label": "Alto Paraná"
      },
      {
        "value": "11",
        "label": "Central"
      },
      {
        "value": "12",
        "label": "Ñeembucú"
      },
      {
        "value": "13",
        "label": "Amambay"
      },
      {
        "value": "14",
        "label": "Canindeyú"
      },
      {
        "value": "15",
        "label": "Presidente Hayes"
      },
      {
        "value": "16",
        "label": "Alto Paraguay"
      },
      {
        "value": "19",
        "label": "Boquerón"
      },
      {
        "value": "2",
        "label": "San Pedro"
      },
      {
        "value": "3",
        "label": "Cordillera"
      },
      {
        "value": "4",
        "label": "Guairá"
      },
      {
        "value": "5",
        "label": "Caaguazú"
      },
      {
        "value": "6",
        "label": "Caazapá"
      },
      {
        "value": "7",
        "label": "Itapúa"
      },
      {
        "value": "8",
        "label": "Misiones"
      },
      {
        "value": "9",
        "label": "Paraguarí"
      },
      {
        "value": "ASU",
        "label": "Asunción"
      }
    ]
  },
  {
    "value": "QA",
    "label": "Qatar",
    "states": [
      {
        "value": "DA",
        "label": "Ad Dawḩah"
      },
      {
        "value": "KH",
        "label": "Al Khawr wa adh Dhakhīrah"
      },
      {
        "value": "MS",
        "label": "Ash Shamāl"
      },
      {
        "value": "RA",
        "label": "Ar Rayyān"
      },
      {
        "value": "SH",
        "label": "Ash Shīḩānīyah"
      },
      {
        "value": "US",
        "label": "Umm Şalāl"
      },
      {
        "value": "WA",
        "label": "Al Wakrah"
      },
      {
        "value": "ZA",
        "label": "Az̧ Z̧a‘āyin"
      }
    ]
  },
  {
    "value": "RE",
    "label": "Reunion",
    "states": []
  },
  {
    "value": "RO",
    "label": "Romania",
    "states": [
      {
        "value": "AB",
        "label": "Alba"
      },
      {
        "value": "AG",
        "label": "Argeș"
      },
      {
        "value": "AR",
        "label": "Arad"
      },
      {
        "value": "B",
        "label": "București"
      },
      {
        "value": "BC",
        "label": "Bacău"
      },
      {
        "value": "BH",
        "label": "Bihor"
      },
      {
        "value": "BN",
        "label": "Bistrița-Năsăud"
      },
      {
        "value": "BR",
        "label": "Brăila"
      },
      {
        "value": "BT",
        "label": "Botoșani"
      },
      {
        "value": "BV",
        "label": "Brașov"
      },
      {
        "value": "BZ",
        "label": "Buzău"
      },
      {
        "value": "CJ",
        "label": "Cluj"
      },
      {
        "value": "CL",
        "label": "Călărași"
      },
      {
        "value": "CS",
        "label": "Caraș-Severin"
      },
      {
        "value": "CT",
        "label": "Constanța"
      },
      {
        "value": "CV",
        "label": "Covasna"
      },
      {
        "value": "DB",
        "label": "Dâmbovița"
      },
      {
        "value": "DJ",
        "label": "Dolj"
      },
      {
        "value": "GJ",
        "label": "Gorj"
      },
      {
        "value": "GL",
        "label": "Galați"
      },
      {
        "value": "GR",
        "label": "Giurgiu"
      },
      {
        "value": "HD",
        "label": "Hunedoara"
      },
      {
        "value": "HR",
        "label": "Harghita"
      },
      {
        "value": "IF",
        "label": "Ilfov"
      },
      {
        "value": "IL",
        "label": "Ialomița"
      },
      {
        "value": "IS",
        "label": "Iași"
      },
      {
        "value": "MH",
        "label": "Mehedinți"
      },
      {
        "value": "MM",
        "label": "Maramureș"
      },
      {
        "value": "MS",
        "label": "Mureș"
      },
      {
        "value": "NT",
        "label": "Neamț"
      },
      {
        "value": "OT",
        "label": "Olt"
      },
      {
        "value": "PH",
        "label": "Prahova"
      },
      {
        "value": "SB",
        "label": "Sibiu"
      },
      {
        "value": "SJ",
        "label": "Sălaj"
      },
      {
        "value": "SM",
        "label": "Satu Mare"
      },
      {
        "value": "SV",
        "label": "Suceava"
      },
      {
        "value": "TL",
        "label": "Tulcea"
      },
      {
        "value": "TM",
        "label": "Timiș"
      },
      {
        "value": "TR",
        "label": "Teleorman"
      },
      {
        "value": "VL",
        "label": "Vâlcea"
      },
      {
        "value": "VN",
        "label": "Vrancea"
      },
      {
        "value": "VS",
        "label": "Vaslui"
      }
    ]
  },
  {
    "value": "RS",
    "label": "Serbia",
    "states": [
      {
        "value": "00",
        "label": "Beograd"
      },
      {
        "value": "01",
        "label": "Severnobački okrug"
      },
      {
        "value": "02",
        "label": "Srednjebanatski okrug"
      },
      {
        "value": "03",
        "label": "Severnobanatski okrug"
      },
      {
        "value": "04",
        "label": "Južnobanatski okrug"
      },
      {
        "value": "05",
        "label": "Zapadnobački okrug"
      },
      {
        "value": "06",
        "label": "Južnobački okrug"
      },
      {
        "value": "07",
        "label": "Sremski okrug"
      },
      {
        "value": "08",
        "label": "Mačvanski okrug"
      },
      {
        "value": "09",
        "label": "Kolubarski okrug"
      },
      {
        "value": "10",
        "label": "Podunavski okrug"
      },
      {
        "value": "11",
        "label": "Braničevski okrug"
      },
      {
        "value": "12",
        "label": "Šumadijski okrug"
      },
      {
        "value": "13",
        "label": "Pomoravski okrug"
      },
      {
        "value": "14",
        "label": "Borski okrug"
      },
      {
        "value": "15",
        "label": "Zaječarski okrug"
      },
      {
        "value": "16",
        "label": "Zlatiborski okrug"
      },
      {
        "value": "17",
        "label": "Moravički okrug"
      },
      {
        "value": "18",
        "label": "Raški okrug"
      },
      {
        "value": "19",
        "label": "Rasinski okrug"
      },
      {
        "value": "20",
        "label": "Nišavski okrug"
      },
      {
        "value": "21",
        "label": "Toplički okrug"
      },
      {
        "value": "22",
        "label": "Pirotski okrug"
      },
      {
        "value": "23",
        "label": "Jablanički okrug"
      },
      {
        "value": "24",
        "label": "Pčinjski okrug"
      },
      {
        "value": "25",
        "label": "Kosovski okrug"
      },
      {
        "value": "26",
        "label": "Pećki okrug"
      },
      {
        "value": "27",
        "label": "Prizrenski okrug"
      },
      {
        "value": "28",
        "label": "Kosovsko-Mitrovački okrug"
      },
      {
        "value": "29",
        "label": "Kosovsko-Pomoravski okrug"
      },
      {
        "value": "KM",
        "label": "Kosovo-Metohija"
      },
      {
        "value": "VO",
        "label": "Vojvodina"
      }
    ]
  },
  {
    "value": "RU",
    "label": "Russian Federation",
    "states": [
      {
        "value": "AD",
        "label": "Adygeya, Respublika"
      },
      {
        "value": "AL",
        "label": "Altay, Respublika"
      },
      {
        "value": "ALT",
        "label": "Altayskiy kray"
      },
      {
        "value": "AMU",
        "label": "Amurskaya oblast'"
      },
      {
        "value": "ARK",
        "label": "Arkhangel'skaya oblast'"
      },
      {
        "value": "AST",
        "label": "Astrakhanskaya oblast'"
      },
      {
        "value": "BA",
        "label": "Bashkortostan, Respublika"
      },
      {
        "value": "BEL",
        "label": "Belgorodskaya oblast'"
      },
      {
        "value": "BRY",
        "label": "Bryanskaya oblast'"
      },
      {
        "value": "BU",
        "label": "Buryatiya, Respublika"
      },
      {
        "value": "CE",
        "label": "Chechenskaya Respublika"
      },
      {
        "value": "CHE",
        "label": "Chelyabinskaya oblast'"
      },
      {
        "value": "CHU",
        "label": "Chukotskiy avtonomnyy okrug"
      },
      {
        "value": "CU",
        "label": "Chuvashskaya Respublika"
      },
      {
        "value": "DA",
        "label": "Dagestan, Respublika"
      },
      {
        "value": "IN",
        "label": "Ingushetiya, Respublika"
      },
      {
        "value": "IRK",
        "label": "Irkutskaya oblast'"
      },
      {
        "value": "IVA",
        "label": "Ivanovskaya oblast'"
      },
      {
        "value": "KAM",
        "label": "Kamchatskiy kray"
      },
      {
        "value": "KB",
        "label": "Kabardino-Balkarskaya Respublika"
      },
      {
        "value": "KC",
        "label": "Karachayevo-Cherkesskaya Respublika"
      },
      {
        "value": "KDA",
        "label": "Krasnodarskiy kray"
      },
      {
        "value": "KEM",
        "label": "Kemerovskaya oblast'"
      },
      {
        "value": "KGD",
        "label": "Kaliningradskaya oblast'"
      },
      {
        "value": "KGN",
        "label": "Kurganskaya oblast'"
      },
      {
        "value": "KHA",
        "label": "Khabarovskiy kray"
      },
      {
        "value": "KHM",
        "label": "Khanty-Mansiyskiy avtonomnyy okrug"
      },
      {
        "value": "KIR",
        "label": "Kirovskaya oblast'"
      },
      {
        "value": "KK",
        "label": "Khakasiya, Respublika"
      },
      {
        "value": "KL",
        "label": "Kalmykiya, Respublika"
      },
      {
        "value": "KLU",
        "label": "Kaluzhskaya oblast'"
      },
      {
        "value": "KO",
        "label": "Komi, Respublika"
      },
      {
        "value": "KOS",
        "label": "Kostromskaya oblast'"
      },
      {
        "value": "KR",
        "label": "Kareliya, Respublika"
      },
      {
        "value": "KRS",
        "label": "Kurskaya oblast'"
      },
      {
        "value": "KYA",
        "label": "Krasnoyarskiy kray"
      },
      {
        "value": "LEN",
        "label": "Leningradskaya oblast'"
      },
      {
        "value": "LIP",
        "label": "Lipetskaya oblast'"
      },
      {
        "value": "MAG",
        "label": "Magadanskaya oblast'"
      },
      {
        "value": "ME",
        "label": "Mariy El, Respublika"
      },
      {
        "value": "MO",
        "label": "Mordoviya, Respublika"
      },
      {
        "value": "MOS",
        "label": "Moskovskaya oblast'"
      },
      {
        "value": "MOW",
        "label": "Moskva"
      },
      {
        "value": "MUR",
        "label": "Murmanskaya oblast'"
      },
      {
        "value": "NEN",
        "label": "Nenetskiy avtonomnyy okrug"
      },
      {
        "value": "NGR",
        "label": "Novgorodskaya oblast'"
      },
      {
        "value": "NIZ",
        "label": "Nizhegorodskaya oblast'"
      },
      {
        "value": "NVS",
        "label": "Novosibirskaya oblast'"
      },
      {
        "value": "OMS",
        "label": "Omskaya oblast'"
      },
      {
        "value": "ORE",
        "label": "Orenburgskaya oblast'"
      },
      {
        "value": "ORL",
        "label": "Orlovskaya oblast'"
      },
      {
        "value": "PER",
        "label": "Permskiy kray"
      },
      {
        "value": "PNZ",
        "label": "Penzenskaya oblast'"
      },
      {
        "value": "PRI",
        "label": "Primorskiy kray"
      },
      {
        "value": "PSK",
        "label": "Pskovskaya oblast'"
      },
      {
        "value": "ROS",
        "label": "Rostovskaya oblast'"
      },
      {
        "value": "RYA",
        "label": "Ryazanskaya oblast'"
      },
      {
        "value": "SA",
        "label": "Sakha, Respublika"
      },
      {
        "value": "SAK",
        "label": "Sakhalinskaya oblast'"
      },
      {
        "value": "SAM",
        "label": "Samarskaya oblast'"
      },
      {
        "value": "SAR",
        "label": "Saratovskaya oblast'"
      },
      {
        "value": "SE",
        "label": "Severnaya Osetiya, Respublika"
      },
      {
        "value": "SMO",
        "label": "Smolenskaya oblast'"
      },
      {
        "value": "SPE",
        "label": "Sankt-Peterburg"
      },
      {
        "value": "STA",
        "label": "Stavropol'skiy kray"
      },
      {
        "value": "SVE",
        "label": "Sverdlovskaya oblast'"
      },
      {
        "value": "TA",
        "label": "Tatarstan, Respublika"
      },
      {
        "value": "TAM",
        "label": "Tambovskaya oblast'"
      },
      {
        "value": "TOM",
        "label": "Tomskaya oblast'"
      },
      {
        "value": "TUL",
        "label": "Tul'skaya oblast'"
      },
      {
        "value": "TVE",
        "label": "Tverskaya oblast'"
      },
      {
        "value": "TY",
        "label": "Tyva, Respublika"
      },
      {
        "value": "TYU",
        "label": "Tyumenskaya oblast'"
      },
      {
        "value": "UD",
        "label": "Udmurtskaya Respublika"
      },
      {
        "value": "ULY",
        "label": "Ul'yanovskaya oblast'"
      },
      {
        "value": "VGG",
        "label": "Volgogradskaya oblast'"
      },
      {
        "value": "VLA",
        "label": "Vladimirskaya oblast'"
      },
      {
        "value": "VLG",
        "label": "Vologodskaya oblast'"
      },
      {
        "value": "VOR",
        "label": "Voronezhskaya oblast'"
      },
      {
        "value": "YAN",
        "label": "Yamalo-Nenetskiy avtonomnyy okrug"
      },
      {
        "value": "YAR",
        "label": "Yaroslavskaya oblast'"
      },
      {
        "value": "YEV",
        "label": "Yevreyskaya avtonomnaya oblast'"
      },
      {
        "value": "ZAB",
        "label": "Zabaykal'skiy kray"
      }
    ]
  },
  {
    "value": "RW",
    "label": "Rwanda",
    "states": [
      {
        "value": "01",
        "label": "City of Kigali"
      },
      {
        "value": "02",
        "label": "Eastern"
      },
      {
        "value": "03",
        "label": "Northern"
      },
      {
        "value": "04",
        "label": "Western"
      },
      {
        "value": "05",
        "label": "Southern"
      }
    ]
  },
  {
    "value": "SA",
    "label": "Saudi Arabia",
    "states": [
      {
        "value": "01",
        "label": "Ar Riyāḑ"
      },
      {
        "value": "02",
        "label": "Makkah al Mukarramah"
      },
      {
        "value": "03",
        "label": "Al Madīnah al Munawwarah"
      },
      {
        "value": "04",
        "label": "Ash Sharqīyah"
      },
      {
        "value": "05",
        "label": "Al Qaşīm"
      },
      {
        "value": "06",
        "label": "Ḩā'il"
      },
      {
        "value": "07",
        "label": "Tabūk"
      },
      {
        "value": "08",
        "label": "Al Ḩudūd ash Shamālīyah"
      },
      {
        "value": "09",
        "label": "Jāzān"
      },
      {
        "value": "10",
        "label": "Najrān"
      },
      {
        "value": "11",
        "label": "Al Bāḩah"
      },
      {
        "value": "12",
        "label": "Al Jawf"
      },
      {
        "value": "14",
        "label": "'Asīr"
      }
    ]
  },
  {
    "value": "SB",
    "label": "Solomon Islands",
    "states": [
      {
        "value": "CE",
        "label": "Central"
      },
      {
        "value": "CH",
        "label": "Choiseul"
      },
      {
        "value": "CT",
        "label": "Capital Territory (Honiara)"
      },
      {
        "value": "GU",
        "label": "Guadalcanal"
      },
      {
        "value": "IS",
        "label": "Isabel"
      },
      {
        "value": "MK",
        "label": "Makira-Ulawa"
      },
      {
        "value": "ML",
        "label": "Malaita"
      },
      {
        "value": "RB",
        "label": "Rennell and Bellona"
      },
      {
        "value": "TE",
        "label": "Temotu"
      },
      {
        "value": "WE",
        "label": "Western"
      }
    ]
  },
  {
    "value": "SC",
    "label": "Seychelles",
    "states": [
      {
        "value": "01",
        "label": "Anse aux Pins"
      },
      {
        "value": "02",
        "label": "Anse Boileau"
      },
      {
        "value": "03",
        "label": "Anse Etoile"
      },
      {
        "value": "04",
        "label": "Au Cap"
      },
      {
        "value": "05",
        "label": "Anse Royale"
      },
      {
        "value": "06",
        "label": "Baie Lazare"
      },
      {
        "value": "07",
        "label": "Baie Sainte Anne"
      },
      {
        "value": "08",
        "label": "Beau Vallon"
      },
      {
        "value": "09",
        "label": "Bel Air"
      },
      {
        "value": "10",
        "label": "Bel Ombre"
      },
      {
        "value": "11",
        "label": "Cascade"
      },
      {
        "value": "12",
        "label": "Glacis"
      },
      {
        "value": "13",
        "label": "Grand Anse Mahe"
      },
      {
        "value": "14",
        "label": "Grand Anse Praslin"
      },
      {
        "value": "15",
        "label": "La Digue"
      },
      {
        "value": "16",
        "label": "English River"
      },
      {
        "value": "17",
        "label": "Mont Buxton"
      },
      {
        "value": "18",
        "label": "Mont Fleuri"
      },
      {
        "value": "19",
        "label": "Plaisance"
      },
      {
        "value": "20",
        "label": "Pointe Larue"
      },
      {
        "value": "21",
        "label": "Port Glaud"
      },
      {
        "value": "22",
        "label": "Saint Louis"
      },
      {
        "value": "23",
        "label": "Takamaka"
      },
      {
        "value": "24",
        "label": "Les Mamelles"
      },
      {
        "value": "25",
        "label": "Roche Caiman"
      },
      {
        "value": "26",
        "label": "Ile Perseverance I"
      },
      {
        "value": "27",
        "label": "Ile Perseverance II"
      }
    ]
  },
  {
    "value": "SD",
    "label": "Sudan",
    "states": [
      {
        "value": "DC",
        "label": "Central Darfur"
      },
      {
        "value": "DE",
        "label": "East Darfur"
      },
      {
        "value": "DN",
        "label": "North Darfur"
      },
      {
        "value": "DS",
        "label": "South Darfur"
      },
      {
        "value": "DW",
        "label": "West Darfur"
      },
      {
        "value": "GD",
        "label": "Gedaref"
      },
      {
        "value": "GK",
        "label": "West Kordofan"
      },
      {
        "value": "GZ",
        "label": "Gezira"
      },
      {
        "value": "KA",
        "label": "Kassala"
      },
      {
        "value": "KH",
        "label": "Khartoum"
      },
      {
        "value": "KN",
        "label": "North Kordofan"
      },
      {
        "value": "KS",
        "label": "South Kordofan"
      },
      {
        "value": "NB",
        "label": "Blue Nile"
      },
      {
        "value": "NO",
        "label": "Northern"
      },
      {
        "value": "NR",
        "label": "River Nile"
      },
      {
        "value": "NW",
        "label": "White Nile"
      },
      {
        "value": "RS",
        "label": "Red Sea"
      },
      {
        "value": "SI",
        "label": "Sennar"
      }
    ]
  },
  {
    "value": "SE",
    "label": "Sweden",
    "states": [
      {
        "value": "AB",
        "label": "Stockholms län"
      },
      {
        "value": "AC",
        "label": "Västerbottens län"
      },
      {
        "value": "BD",
        "label": "Norrbottens län"
      },
      {
        "value": "C",
        "label": "Uppsala län"
      },
      {
        "value": "D",
        "label": "Södermanlands län"
      },
      {
        "value": "E",
        "label": "Östergötlands län"
      },
      {
        "value": "F",
        "label": "Jönköpings län"
      },
      {
        "value": "G",
        "label": "Kronobergs län"
      },
      {
        "value": "H",
        "label": "Kalmar län"
      },
      {
        "value": "I",
        "label": "Gotlands län"
      },
      {
        "value": "K",
        "label": "Blekinge län"
      },
      {
        "value": "M",
        "label": "Skåne län"
      },
      {
        "value": "N",
        "label": "Hallands län"
      },
      {
        "value": "O",
        "label": "Västra Götalands län"
      },
      {
        "value": "S",
        "label": "Värmlands län"
      },
      {
        "value": "T",
        "label": "Örebro län"
      },
      {
        "value": "U",
        "label": "Västmanlands län"
      },
      {
        "value": "W",
        "label": "Dalarnas län"
      },
      {
        "value": "X",
        "label": "Gävleborgs län"
      },
      {
        "value": "Y",
        "label": "Västernorrlands län"
      },
      {
        "value": "Z",
        "label": "Jämtlands län"
      }
    ]
  },
  {
    "value": "SG",
    "label": "Singapore",
    "states": [
      {
        "value": "01",
        "label": "Central Singapore"
      },
      {
        "value": "02",
        "label": "North East"
      },
      {
        "value": "03",
        "label": "North West"
      },
      {
        "value": "04",
        "label": "South East"
      },
      {
        "value": "05",
        "label": "South West"
      }
    ]
  },
  {
    "value": "SH",
    "label": "Saint Helena, Ascension and Tristan da Cunha",
    "states": [
      {
        "value": "AC",
        "label": "Ascension"
      },
      {
        "value": "HL",
        "label": "Saint Helena"
      },
      {
        "value": "TA",
        "label": "Tristan da Cunha"
      }
    ]
  },
  {
    "value": "SI",
    "label": "Slovenia",
    "states": [
      {
        "value": "001",
        "label": "Ajdovščina"
      },
      {
        "value": "002",
        "label": "Beltinci"
      },
      {
        "value": "003",
        "label": "Bled"
      },
      {
        "value": "004",
        "label": "Bohinj"
      },
      {
        "value": "005",
        "label": "Borovnica"
      },
      {
        "value": "006",
        "label": "Bovec"
      },
      {
        "value": "007",
        "label": "Brda"
      },
      {
        "value": "008",
        "label": "Brezovica"
      },
      {
        "value": "009",
        "label": "Brežice"
      },
      {
        "value": "010",
        "label": "Tišina"
      },
      {
        "value": "011",
        "label": "Celje"
      },
      {
        "value": "012",
        "label": "Cerklje na Gorenjskem"
      },
      {
        "value": "013",
        "label": "Cerknica"
      },
      {
        "value": "014",
        "label": "Cerkno"
      },
      {
        "value": "015",
        "label": "Črenšovci"
      },
      {
        "value": "016",
        "label": "Črna na Koroškem"
      },
      {
        "value": "017",
        "label": "Črnomelj"
      },
      {
        "value": "018",
        "label": "Destrnik"
      },
      {
        "value": "019",
        "label": "Divača"
      },
      {
        "value": "020",
        "label": "Dobrepolje"
      },
      {
        "value": "021",
        "label": "Dobrova-Polhov Gradec"
      },
      {
        "value": "022",
        "label": "Dol pri Ljubljani"
      },
      {
        "value": "023",
        "label": "Domžale"
      },
      {
        "value": "024",
        "label": "Dornava"
      },
      {
        "value": "025",
        "label": "Dravograd"
      },
      {
        "value": "026",
        "label": "Duplek"
      },
      {
        "value": "027",
        "label": "Gorenja vas-Poljane"
      },
      {
        "value": "028",
        "label": "Gorišnica"
      },
      {
        "value": "029",
        "label": "Gornja Radgona"
      },
      {
        "value": "030",
        "label": "Gornji Grad"
      },
      {
        "value": "031",
        "label": "Gornji Petrovci"
      },
      {
        "value": "032",
        "label": "Grosuplje"
      },
      {
        "value": "033",
        "label": "Šalovci"
      },
      {
        "value": "034",
        "label": "Hrastnik"
      },
      {
        "value": "035",
        "label": "Hrpelje-Kozina"
      },
      {
        "value": "036",
        "label": "Idrija"
      },
      {
        "value": "037",
        "label": "Ig"
      },
      {
        "value": "038",
        "label": "Ilirska Bistrica"
      },
      {
        "value": "039",
        "label": "Ivančna Gorica"
      },
      {
        "value": "040",
        "label": "Isola"
      },
      {
        "value": "041",
        "label": "Jesenice"
      },
      {
        "value": "042",
        "label": "Juršinci"
      },
      {
        "value": "043",
        "label": "Kamnik"
      },
      {
        "value": "044",
        "label": "Kanal ob Soči"
      },
      {
        "value": "045",
        "label": "Kidričevo"
      },
      {
        "value": "046",
        "label": "Kobarid"
      },
      {
        "value": "047",
        "label": "Kobilje"
      },
      {
        "value": "048",
        "label": "Kočevje"
      },
      {
        "value": "049",
        "label": "Komen"
      },
      {
        "value": "050",
        "label": "Capodistria"
      },
      {
        "value": "051",
        "label": "Kozje"
      },
      {
        "value": "052",
        "label": "Kranj"
      },
      {
        "value": "053",
        "label": "Kranjska Gora"
      },
      {
        "value": "054",
        "label": "Krško"
      },
      {
        "value": "055",
        "label": "Kungota"
      },
      {
        "value": "056",
        "label": "Kuzma"
      },
      {
        "value": "057",
        "label": "Laško"
      },
      {
        "value": "058",
        "label": "Lenart"
      },
      {
        "value": "059",
        "label": "Lendva"
      },
      {
        "value": "060",
        "label": "Litija"
      },
      {
        "value": "061",
        "label": "Ljubljana"
      },
      {
        "value": "062",
        "label": "Ljubno"
      },
      {
        "value": "063",
        "label": "Ljutomer"
      },
      {
        "value": "064",
        "label": "Logatec"
      },
      {
        "value": "065",
        "label": "Loška dolina"
      },
      {
        "value": "066",
        "label": "Loški Potok"
      },
      {
        "value": "067",
        "label": "Luče"
      },
      {
        "value": "068",
        "label": "Lukovica"
      },
      {
        "value": "069",
        "label": "Majšperk"
      },
      {
        "value": "070",
        "label": "Maribor"
      },
      {
        "value": "071",
        "label": "Medvode"
      },
      {
        "value": "072",
        "label": "Mengeš"
      },
      {
        "value": "073",
        "label": "Metlika"
      },
      {
        "value": "074",
        "label": "Mežica"
      },
      {
        "value": "075",
        "label": "Miren-Kostanjevica"
      },
      {
        "value": "076",
        "label": "Mislinja"
      },
      {
        "value": "077",
        "label": "Moravče"
      },
      {
        "value": "078",
        "label": "Moravske Toplice"
      },
      {
        "value": "079",
        "label": "Mozirje"
      },
      {
        "value": "080",
        "label": "Murska Sobota"
      },
      {
        "value": "081",
        "label": "Muta"
      },
      {
        "value": "082",
        "label": "Naklo"
      },
      {
        "value": "083",
        "label": "Nazarje"
      },
      {
        "value": "084",
        "label": "Nova Gorica"
      },
      {
        "value": "085",
        "label": "Novo Mesto"
      },
      {
        "value": "086",
        "label": "Odranci"
      },
      {
        "value": "087",
        "label": "Ormož"
      },
      {
        "value": "088",
        "label": "Osilnica"
      },
      {
        "value": "089",
        "label": "Pesnica"
      },
      {
        "value": "090",
        "label": "Pirano"
      },
      {
        "value": "091",
        "label": "Pivka"
      },
      {
        "value": "092",
        "label": "Podčetrtek"
      },
      {
        "value": "093",
        "label": "Podvelka"
      },
      {
        "value": "094",
        "label": "Postojna"
      },
      {
        "value": "095",
        "label": "Preddvor"
      },
      {
        "value": "096",
        "label": "Ptuj"
      },
      {
        "value": "097",
        "label": "Puconci"
      },
      {
        "value": "098",
        "label": "Rače-Fram"
      },
      {
        "value": "099",
        "label": "Radeče"
      },
      {
        "value": "100",
        "label": "Radenci"
      },
      {
        "value": "101",
        "label": "Radlje ob Dravi"
      },
      {
        "value": "102",
        "label": "Radovljica"
      },
      {
        "value": "103",
        "label": "Ravne na Koroškem"
      },
      {
        "value": "104",
        "label": "Ribnica"
      },
      {
        "value": "105",
        "label": "Rogašovci"
      },
      {
        "value": "106",
        "label": "Rogaška Slatina"
      },
      {
        "value": "107",
        "label": "Rogatec"
      },
      {
        "value": "108",
        "label": "Ruše"
      },
      {
        "value": "109",
        "label": "Semič"
      },
      {
        "value": "110",
        "label": "Sevnica"
      },
      {
        "value": "111",
        "label": "Sežana"
      },
      {
        "value": "112",
        "label": "Slovenj Gradec"
      },
      {
        "value": "113",
        "label": "Slovenska Bistrica"
      },
      {
        "value": "114",
        "label": "Slovenske Konjice"
      },
      {
        "value": "115",
        "label": "Starše"
      },
      {
        "value": "116",
        "label": "Sveti Jurij ob Ščavnici"
      },
      {
        "value": "117",
        "label": "Šenčur"
      },
      {
        "value": "118",
        "label": "Šentilj"
      },
      {
        "value": "119",
        "label": "Šentjernej"
      },
      {
        "value": "120",
        "label": "Šentjur"
      },
      {
        "value": "121",
        "label": "Škocjan"
      },
      {
        "value": "122",
        "label": "Škofja Loka"
      },
      {
        "value": "123",
        "label": "Škofljica"
      },
      {
        "value": "124",
        "label": "Šmarje pri Jelšah"
      },
      {
        "value": "125",
        "label": "Šmartno ob Paki"
      },
      {
        "value": "126",
        "label": "Šoštanj"
      },
      {
        "value": "127",
        "label": "Štore"
      },
      {
        "value": "128",
        "label": "Tolmin"
      },
      {
        "value": "129",
        "label": "Trbovlje"
      },
      {
        "value": "130",
        "label": "Trebnje"
      },
      {
        "value": "131",
        "label": "Tržič"
      },
      {
        "value": "132",
        "label": "Turnišče"
      },
      {
        "value": "133",
        "label": "Velenje"
      },
      {
        "value": "134",
        "label": "Velike Lašče"
      },
      {
        "value": "135",
        "label": "Videm"
      },
      {
        "value": "136",
        "label": "Vipava"
      },
      {
        "value": "137",
        "label": "Vitanje"
      },
      {
        "value": "138",
        "label": "Vodice"
      },
      {
        "value": "139",
        "label": "Vojnik"
      },
      {
        "value": "140",
        "label": "Vrhnika"
      },
      {
        "value": "141",
        "label": "Vuzenica"
      },
      {
        "value": "142",
        "label": "Zagorje ob Savi"
      },
      {
        "value": "143",
        "label": "Zavrč"
      },
      {
        "value": "144",
        "label": "Zreče"
      },
      {
        "value": "146",
        "label": "Železniki"
      },
      {
        "value": "147",
        "label": "Žiri"
      },
      {
        "value": "148",
        "label": "Benedikt"
      },
      {
        "value": "149",
        "label": "Bistrica ob Sotli"
      },
      {
        "value": "150",
        "label": "Bloke"
      },
      {
        "value": "151",
        "label": "Braslovče"
      },
      {
        "value": "152",
        "label": "Cankova"
      },
      {
        "value": "153",
        "label": "Cerkvenjak"
      },
      {
        "value": "154",
        "label": "Dobje"
      },
      {
        "value": "155",
        "label": "Dobrna"
      },
      {
        "value": "156",
        "label": "Dobronak"
      },
      {
        "value": "157",
        "label": "Dolenjske Toplice"
      },
      {
        "value": "158",
        "label": "Grad"
      },
      {
        "value": "159",
        "label": "Hajdina"
      },
      {
        "value": "160",
        "label": "Hoče-Slivnica"
      },
      {
        "value": "161",
        "label": "Hodos"
      },
      {
        "value": "162",
        "label": "Horjul"
      },
      {
        "value": "163",
        "label": "Jezersko"
      },
      {
        "value": "164",
        "label": "Komenda"
      },
      {
        "value": "165",
        "label": "Kostel"
      },
      {
        "value": "166",
        "label": "Križevci"
      },
      {
        "value": "167",
        "label": "Lovrenc na Pohorju"
      },
      {
        "value": "168",
        "label": "Markovci"
      },
      {
        "value": "169",
        "label": "Miklavž na Dravskem polju"
      },
      {
        "value": "170",
        "label": "Mirna Peč"
      },
      {
        "value": "171",
        "label": "Oplotnica"
      },
      {
        "value": "172",
        "label": "Podlehnik"
      },
      {
        "value": "173",
        "label": "Polzela"
      },
      {
        "value": "174",
        "label": "Prebold"
      },
      {
        "value": "175",
        "label": "Prevalje"
      },
      {
        "value": "176",
        "label": "Razkrižje"
      },
      {
        "value": "177",
        "label": "Ribnica na Pohorju"
      },
      {
        "value": "178",
        "label": "Selnica ob Dravi"
      },
      {
        "value": "179",
        "label": "Sodražica"
      },
      {
        "value": "180",
        "label": "Solčava"
      },
      {
        "value": "181",
        "label": "Sveta Ana"
      },
      {
        "value": "182",
        "label": "Sveti Andraž v Slovenskih goricah"
      },
      {
        "value": "183",
        "label": "Šempeter-Vrtojba"
      },
      {
        "value": "184",
        "label": "Tabor"
      },
      {
        "value": "185",
        "label": "Trnovska Vas"
      },
      {
        "value": "186",
        "label": "Trzin"
      },
      {
        "value": "187",
        "label": "Velika Polana"
      },
      {
        "value": "188",
        "label": "Veržej"
      },
      {
        "value": "189",
        "label": "Vransko"
      },
      {
        "value": "190",
        "label": "Žalec"
      },
      {
        "value": "191",
        "label": "Žetale"
      },
      {
        "value": "192",
        "label": "Žirovnica"
      },
      {
        "value": "193",
        "label": "Žužemberk"
      },
      {
        "value": "194",
        "label": "Šmartno pri Litiji"
      },
      {
        "value": "195",
        "label": "Apače"
      },
      {
        "value": "196",
        "label": "Cirkulane"
      },
      {
        "value": "197",
        "label": "Kostanjevica na Krki"
      },
      {
        "value": "198",
        "label": "Makole"
      },
      {
        "value": "199",
        "label": "Mokronog-Trebelno"
      },
      {
        "value": "200",
        "label": "Poljčane"
      },
      {
        "value": "201",
        "label": "Renče-Vogrsko"
      },
      {
        "value": "202",
        "label": "Središče ob Dravi"
      },
      {
        "value": "203",
        "label": "Straža"
      },
      {
        "value": "204",
        "label": "Sveta Trojica v Slovenskih goricah"
      },
      {
        "value": "205",
        "label": "Sveti Tomaž"
      },
      {
        "value": "206",
        "label": "Šmarješke Toplice"
      },
      {
        "value": "207",
        "label": "Gorje"
      },
      {
        "value": "208",
        "label": "Log-Dragomer"
      },
      {
        "value": "209",
        "label": "Rečica ob Savinji"
      },
      {
        "value": "210",
        "label": "Sveti Jurij v Slovenskih goricah"
      },
      {
        "value": "211",
        "label": "Šentrupert"
      },
      {
        "value": "212",
        "label": "Mirna"
      },
      {
        "value": "213",
        "label": "Ancarano"
      }
    ]
  },
  {
    "value": "SJ",
    "label": "Svalbard and Jan Mayen",
    "states": []
  },
  {
    "value": "SK",
    "label": "Slovakia",
    "states": [
      {
        "value": "BC",
        "label": "Banskobystrický kraj"
      },
      {
        "value": "BL",
        "label": "Bratislavský kraj"
      },
      {
        "value": "KI",
        "label": "Košický kraj"
      },
      {
        "value": "NI",
        "label": "Nitriansky kraj"
      },
      {
        "value": "PV",
        "label": "Prešovský kraj"
      },
      {
        "value": "TA",
        "label": "Trnavský kraj"
      },
      {
        "value": "TC",
        "label": "Trenčiansky kraj"
      },
      {
        "value": "ZI",
        "label": "Žilinský kraj"
      }
    ]
  },
  {
    "value": "SL",
    "label": "Sierra Leone",
    "states": [
      {
        "value": "E",
        "label": "Eastern"
      },
      {
        "value": "N",
        "label": "Northern"
      },
      {
        "value": "NW",
        "label": "North Western"
      },
      {
        "value": "S",
        "label": "Southern"
      },
      {
        "value": "W",
        "label": "Western Area (Freetown)"
      }
    ]
  },
  {
    "value": "SM",
    "label": "San Marino",
    "states": [
      {
        "value": "01",
        "label": "Acquaviva"
      },
      {
        "value": "02",
        "label": "Chiesanuova"
      },
      {
        "value": "03",
        "label": "Domagnano"
      },
      {
        "value": "04",
        "label": "Faetano"
      },
      {
        "value": "05",
        "label": "Fiorentino"
      },
      {
        "value": "06",
        "label": "Borgo Maggiore"
      },
      {
        "value": "07",
        "label": "San Marino"
      },
      {
        "value": "08",
        "label": "Montegiardino"
      },
      {
        "value": "09",
        "label": "Serravalle"
      }
    ]
  },
  {
    "value": "SN",
    "label": "Senegal",
    "states": [
      {
        "value": "DB",
        "label": "Diourbel"
      },
      {
        "value": "DK",
        "label": "Dakar"
      },
      {
        "value": "FK",
        "label": "Fatick"
      },
      {
        "value": "KA",
        "label": "Kaffrine"
      },
      {
        "value": "KD",
        "label": "Kolda"
      },
      {
        "value": "KE",
        "label": "Kédougou"
      },
      {
        "value": "KL",
        "label": "Kaolack"
      },
      {
        "value": "LG",
        "label": "Louga"
      },
      {
        "value": "MT",
        "label": "Matam"
      },
      {
        "value": "SE",
        "label": "Sédhiou"
      },
      {
        "value": "SL",
        "label": "Saint-Louis"
      },
      {
        "value": "TC",
        "label": "Tambacounda"
      },
      {
        "value": "TH",
        "label": "Thiès"
      },
      {
        "value": "ZG",
        "label": "Ziguinchor"
      }
    ]
  },
  {
    "value": "SO",
    "label": "Somalia",
    "states": [
      {
        "value": "AW",
        "label": "Awdal"
      },
      {
        "value": "BK",
        "label": "Bakool"
      },
      {
        "value": "BN",
        "label": "Banaadir"
      },
      {
        "value": "BR",
        "label": "Bari"
      },
      {
        "value": "BY",
        "label": "Bay"
      },
      {
        "value": "GA",
        "label": "Galguduud"
      },
      {
        "value": "GE",
        "label": "Gedo"
      },
      {
        "value": "HI",
        "label": "Hiiraan"
      },
      {
        "value": "JD",
        "label": "Jubbada Dhexe"
      },
      {
        "value": "JH",
        "label": "Jubbada Hoose"
      },
      {
        "value": "MU",
        "label": "Mudug"
      },
      {
        "value": "NU",
        "label": "Nugaal"
      },
      {
        "value": "SA",
        "label": "Sanaag"
      },
      {
        "value": "SD",
        "label": "Shabeellaha Dhexe"
      },
      {
        "value": "SH",
        "label": "Shabeellaha Hoose"
      },
      {
        "value": "SO",
        "label": "Sool"
      },
      {
        "value": "TO",
        "label": "Togdheer"
      },
      {
        "value": "WO",
        "label": "Woqooyi Galbeed"
      }
    ]
  },
  {
    "value": "SR",
    "label": "Suriname",
    "states": [
      {
        "value": "BR",
        "label": "Brokopondo"
      },
      {
        "value": "CM",
        "label": "Commewijne"
      },
      {
        "value": "CR",
        "label": "Coronie"
      },
      {
        "value": "MA",
        "label": "Marowijne"
      },
      {
        "value": "NI",
        "label": "Nickerie"
      },
      {
        "value": "PM",
        "label": "Paramaribo"
      },
      {
        "value": "PR",
        "label": "Para"
      },
      {
        "value": "SA",
        "label": "Saramacca"
      },
      {
        "value": "SI",
        "label": "Sipaliwini"
      },
      {
        "value": "WA",
        "label": "Wanica"
      }
    ]
  },
  {
    "value": "SS",
    "label": "South Sudan",
    "states": [
      {
        "value": "BN",
        "label": "Northern Bahr el Ghazal"
      },
      {
        "value": "BW",
        "label": "Western Bahr el Ghazal"
      },
      {
        "value": "EC",
        "label": "Central Equatoria"
      },
      {
        "value": "EE",
        "label": "Eastern Equatoria"
      },
      {
        "value": "EW",
        "label": "Western Equatoria"
      },
      {
        "value": "JG",
        "label": "Jonglei"
      },
      {
        "value": "LK",
        "label": "Lakes"
      },
      {
        "value": "NU",
        "label": "Upper Nile"
      },
      {
        "value": "UY",
        "label": "Unity"
      },
      {
        "value": "WR",
        "label": "Warrap"
      }
    ]
  },
  {
    "value": "ST",
    "label": "Sao Tome and Principe",
    "states": [
      {
        "value": "01",
        "label": "Água Grande"
      },
      {
        "value": "02",
        "label": "Cantagalo"
      },
      {
        "value": "03",
        "label": "Caué"
      },
      {
        "value": "04",
        "label": "Lembá"
      },
      {
        "value": "05",
        "label": "Lobata"
      },
      {
        "value": "06",
        "label": "Mé-Zóchi"
      },
      {
        "value": "P",
        "label": "Príncipe"
      }
    ]
  },
  {
    "value": "SV",
    "label": "El Salvador",
    "states": [
      {
        "value": "AH",
        "label": "Ahuachapán"
      },
      {
        "value": "CA",
        "label": "Cabañas"
      },
      {
        "value": "CH",
        "label": "Chalatenango"
      },
      {
        "value": "CU",
        "label": "Cuscatlán"
      },
      {
        "value": "LI",
        "label": "La Libertad"
      },
      {
        "value": "MO",
        "label": "Morazán"
      },
      {
        "value": "PA",
        "label": "La Paz"
      },
      {
        "value": "SA",
        "label": "Santa Ana"
      },
      {
        "value": "SM",
        "label": "San Miguel"
      },
      {
        "value": "SO",
        "label": "Sonsonate"
      },
      {
        "value": "SS",
        "label": "San Salvador"
      },
      {
        "value": "SV",
        "label": "San Vicente"
      },
      {
        "value": "UN",
        "label": "La Unión"
      },
      {
        "value": "US",
        "label": "Usulután"
      }
    ]
  },
  {
    "value": "SX",
    "label": "Sint Maarten (Dutch part)",
    "states": []
  },
  {
    "value": "SY",
    "label": "Syrian Arab Republic",
    "states": [
      {
        "value": "DI",
        "label": "Dimashq"
      },
      {
        "value": "DR",
        "label": "Dar'ā"
      },
      {
        "value": "DY",
        "label": "Dayr az Zawr"
      },
      {
        "value": "HA",
        "label": "Al Ḩasakah"
      },
      {
        "value": "HI",
        "label": "Ḩimş"
      },
      {
        "value": "HL",
        "label": "Ḩalab"
      },
      {
        "value": "HM",
        "label": "Ḩamāh"
      },
      {
        "value": "ID",
        "label": "Idlib"
      },
      {
        "value": "LA",
        "label": "Al Lādhiqīyah"
      },
      {
        "value": "QU",
        "label": "Al Qunayţirah"
      },
      {
        "value": "RA",
        "label": "Ar Raqqah"
      },
      {
        "value": "RD",
        "label": "Rīf Dimashq"
      },
      {
        "value": "SU",
        "label": "As Suwaydā'"
      },
      {
        "value": "TA",
        "label": "Ţarţūs"
      }
    ]
  },
  {
    "value": "SZ",
    "label": "Swaziland",
    "states": [
      {
        "value": "HH",
        "label": "Hhohho"
      },
      {
        "value": "LU",
        "label": "Lubombo"
      },
      {
        "value": "MA",
        "label": "Manzini"
      },
      {
        "value": "SH",
        "label": "Shiselweni"
      }
    ]
  },
  {
    "value": "TC",
    "label": "Turks and Caicos Islands",
    "states": []
  },
  {
    "value": "TD",
    "label": "Chad",
    "states": [
      {
        "value": "BA",
        "label": "Batha"
      },
      {
        "value": "BG",
        "label": "Barh-el-Ghazal"
      },
      {
        "value": "BO",
        "label": "Borkou"
      },
      {
        "value": "CB",
        "label": "Chari-Baguirmi"
      },
      {
        "value": "EE",
        "label": "Ennedi-Est"
      },
      {
        "value": "EO",
        "label": "Ennedi-Ouest"
      },
      {
        "value": "GR",
        "label": "Guéra"
      },
      {
        "value": "HL",
        "label": "Hadjer Lamis"
      },
      {
        "value": "KA",
        "label": "Kanem"
      },
      {
        "value": "LC",
        "label": "Lac"
      },
      {
        "value": "LO",
        "label": "Logone-Occidental"
      },
      {
        "value": "LR",
        "label": "Logone-Oriental"
      },
      {
        "value": "MA",
        "label": "Mandoul"
      },
      {
        "value": "MC",
        "label": "Moyen-Chari"
      },
      {
        "value": "ME",
        "label": "Mayo-Kebbi-Est"
      },
      {
        "value": "MO",
        "label": "Mayo-Kebbi-Ouest"
      },
      {
        "value": "ND",
        "label": "Ville de Ndjamena"
      },
      {
        "value": "OD",
        "label": "Ouaddaï"
      },
      {
        "value": "SA",
        "label": "Salamat"
      },
      {
        "value": "SI",
        "label": "Sila"
      },
      {
        "value": "TA",
        "label": "Tandjilé"
      },
      {
        "value": "TI",
        "label": "Tibesti"
      },
      {
        "value": "WF",
        "label": "Wadi Fira"
      }
    ]
  },
  {
    "value": "TF",
    "label": "French Southern Territories",
    "states": []
  },
  {
    "value": "TG",
    "label": "Togo",
    "states": [
      {
        "value": "C",
        "label": "Centrale"
      },
      {
        "value": "K",
        "label": "Kara"
      },
      {
        "value": "M",
        "label": "Maritime (Région)"
      },
      {
        "value": "P",
        "label": "Plateaux"
      },
      {
        "value": "S",
        "label": "Savanes"
      }
    ]
  },
  {
    "value": "TH",
    "label": "Thailand",
    "states": [
      {
        "value": "10",
        "label": "Bangkok"
      },
      {
        "value": "11",
        "label": "Samut Prakan"
      },
      {
        "value": "12",
        "label": "Nonthaburi"
      },
      {
        "value": "13",
        "label": "Pathum Thani"
      },
      {
        "value": "14",
        "label": "Phra Nakhon Si Ayutthaya"
      },
      {
        "value": "15",
        "label": "Ang Thong"
      },
      {
        "value": "16",
        "label": "Lop Buri"
      },
      {
        "value": "17",
        "label": "Sing Buri"
      },
      {
        "value": "18",
        "label": "Chai Nat"
      },
      {
        "value": "19",
        "label": "Saraburi"
      },
      {
        "value": "20",
        "label": "Chon Buri"
      },
      {
        "value": "21",
        "label": "Rayong"
      },
      {
        "value": "22",
        "label": "Chanthaburi"
      },
      {
        "value": "23",
        "label": "Trat"
      },
      {
        "value": "24",
        "label": "Chachoengsao"
      },
      {
        "value": "25",
        "label": "Prachin Buri"
      },
      {
        "value": "26",
        "label": "Nakhon Nayok"
      },
      {
        "value": "27",
        "label": "Sa Kaeo"
      },
      {
        "value": "30",
        "label": "Nakhon Ratchasima"
      },
      {
        "value": "31",
        "label": "Buri Ram"
      },
      {
        "value": "32",
        "label": "Surin"
      },
      {
        "value": "33",
        "label": "Si Sa Ket"
      },
      {
        "value": "34",
        "label": "Ubon Ratchathani"
      },
      {
        "value": "35",
        "label": "Yasothon"
      },
      {
        "value": "36",
        "label": "Chaiyaphum"
      },
      {
        "value": "37",
        "label": "Amnat Charoen"
      },
      {
        "value": "38",
        "label": "Bueng Kan"
      },
      {
        "value": "39",
        "label": "Nong Bua Lam Phu"
      },
      {
        "value": "40",
        "label": "Khon Kaen"
      },
      {
        "value": "41",
        "label": "Udon Thani"
      },
      {
        "value": "42",
        "label": "Loei"
      },
      {
        "value": "43",
        "label": "Nong Khai"
      },
      {
        "value": "44",
        "label": "Maha Sarakham"
      },
      {
        "value": "45",
        "label": "Roi Et"
      },
      {
        "value": "46",
        "label": "Kalasin"
      },
      {
        "value": "47",
        "label": "Sakon Nakhon"
      },
      {
        "value": "48",
        "label": "Nakhon Phanom"
      },
      {
        "value": "49",
        "label": "Mukdahan"
      },
      {
        "value": "50",
        "label": "Chiang Mai"
      },
      {
        "value": "51",
        "label": "Lamphun"
      },
      {
        "value": "52",
        "label": "Lampang"
      },
      {
        "value": "53",
        "label": "Uttaradit"
      },
      {
        "value": "54",
        "label": "Phrae"
      },
      {
        "value": "55",
        "label": "Nan"
      },
      {
        "value": "56",
        "label": "Phayao"
      },
      {
        "value": "57",
        "label": "Chiang Rai"
      },
      {
        "value": "58",
        "label": "Mae Hong Son"
      },
      {
        "value": "60",
        "label": "Nakhon Sawan"
      },
      {
        "value": "61",
        "label": "Uthai Thani"
      },
      {
        "value": "62",
        "label": "Kamphaeng Phet"
      },
      {
        "value": "63",
        "label": "Tak"
      },
      {
        "value": "64",
        "label": "Sukhothai"
      },
      {
        "value": "65",
        "label": "Phitsanulok"
      },
      {
        "value": "66",
        "label": "Phichit"
      },
      {
        "value": "67",
        "label": "Phetchabun"
      },
      {
        "value": "70",
        "label": "Ratchaburi"
      },
      {
        "value": "71",
        "label": "Kanchanaburi"
      },
      {
        "value": "72",
        "label": "Suphan Buri"
      },
      {
        "value": "73",
        "label": "Nakhon Pathom"
      },
      {
        "value": "74",
        "label": "Samut Sakhon"
      },
      {
        "value": "75",
        "label": "Samut Songkhram"
      },
      {
        "value": "76",
        "label": "Phetchaburi"
      },
      {
        "value": "77",
        "label": "Prachuap Khiri Khan"
      },
      {
        "value": "80",
        "label": "Nakhon Si Thammarat"
      },
      {
        "value": "81",
        "label": "Krabi"
      },
      {
        "value": "82",
        "label": "Phangnga"
      },
      {
        "value": "83",
        "label": "Phuket"
      },
      {
        "value": "84",
        "label": "Surat Thani"
      },
      {
        "value": "85",
        "label": "Ranong"
      },
      {
        "value": "86",
        "label": "Chumphon"
      },
      {
        "value": "90",
        "label": "Songkhla"
      },
      {
        "value": "91",
        "label": "Satun"
      },
      {
        "value": "92",
        "label": "Trang"
      },
      {
        "value": "93",
        "label": "Phatthalung"
      },
      {
        "value": "94",
        "label": "Pattani"
      },
      {
        "value": "95",
        "label": "Yala"
      },
      {
        "value": "96",
        "label": "Narathiwat"
      },
      {
        "value": "S",
        "label": "Phatthaya"
      }
    ]
  },
  {
    "value": "TJ",
    "label": "Tajikistan",
    "states": [
      {
        "value": "DU",
        "label": "Dushanbe"
      },
      {
        "value": "GB",
        "label": "Kŭhistoni Badakhshon"
      },
      {
        "value": "KT",
        "label": "Khatlon"
      },
      {
        "value": "RA",
        "label": "nohiyahoi tobei jumhurí"
      },
      {
        "value": "SU",
        "label": "Sughd"
      }
    ]
  },
  {
    "value": "TK",
    "label": "Tokelau",
    "states": []
  },
  {
    "value": "TL",
    "label": "Timor-Leste",
    "states": [
      {
        "value": "AL",
        "label": "Aileu"
      },
      {
        "value": "AN",
        "label": "Ainaro"
      },
      {
        "value": "BA",
        "label": "Baucau"
      },
      {
        "value": "BO",
        "label": "Bobonaro"
      },
      {
        "value": "CO",
        "label": "Cova Lima"
      },
      {
        "value": "DI",
        "label": "Díli"
      },
      {
        "value": "ER",
        "label": "Ermera"
      },
      {
        "value": "LA",
        "label": "Lautém"
      },
      {
        "value": "LI",
        "label": "Liquiça"
      },
      {
        "value": "MF",
        "label": "Manufahi"
      },
      {
        "value": "MT",
        "label": "Manatuto"
      },
      {
        "value": "OE",
        "label": "Oecussi"
      },
      {
        "value": "VI",
        "label": "Viqueque"
      }
    ]
  },
  {
    "value": "TM",
    "label": "Turkmenistan",
    "states": [
      {
        "value": "A",
        "label": "Ahal"
      },
      {
        "value": "B",
        "label": "Balkan"
      },
      {
        "value": "D",
        "label": "Daşoguz"
      },
      {
        "value": "L",
        "label": "Lebap"
      },
      {
        "value": "M",
        "label": "Mary"
      },
      {
        "value": "S",
        "label": "Aşgabat"
      }
    ]
  },
  {
    "value": "TN",
    "label": "Tunisia",
    "states": [
      {
        "value": "11",
        "label": "Tunis"
      },
      {
        "value": "12",
        "label": "L'Ariana"
      },
      {
        "value": "13",
        "label": "Ben Arous"
      },
      {
        "value": "14",
        "label": "La Manouba"
      },
      {
        "value": "21",
        "label": "Nabeul"
      },
      {
        "value": "22",
        "label": "Zaghouan"
      },
      {
        "value": "23",
        "label": "Bizerte"
      },
      {
        "value": "31",
        "label": "Béja"
      },
      {
        "value": "32",
        "label": "Jendouba"
      },
      {
        "value": "33",
        "label": "Le Kef"
      },
      {
        "value": "34",
        "label": "Siliana"
      },
      {
        "value": "41",
        "label": "Kairouan"
      },
      {
        "value": "42",
        "label": "Kasserine"
      },
      {
        "value": "43",
        "label": "Sidi Bouzid"
      },
      {
        "value": "51",
        "label": "Sousse"
      },
      {
        "value": "52",
        "label": "Monastir"
      },
      {
        "value": "53",
        "label": "Mahdia"
      },
      {
        "value": "61",
        "label": "Sfax"
      },
      {
        "value": "71",
        "label": "Gafsa"
      },
      {
        "value": "72",
        "label": "Tozeur"
      },
      {
        "value": "73",
        "label": "Kébili"
      },
      {
        "value": "81",
        "label": "Gabès"
      },
      {
        "value": "82",
        "label": "Médenine"
      },
      {
        "value": "83",
        "label": "Tataouine"
      }
    ]
  },
  {
    "value": "TO",
    "label": "Tonga",
    "states": [
      {
        "value": "01",
        "label": "'Eua"
      },
      {
        "value": "02",
        "label": "Ha'apai"
      },
      {
        "value": "03",
        "label": "Niuas"
      },
      {
        "value": "04",
        "label": "Tongatapu"
      },
      {
        "value": "05",
        "label": "Vava'u"
      }
    ]
  },
  {
    "value": "TR",
    "label": "Turkey",
    "states": [
      {
        "value": "01",
        "label": "Adana"
      },
      {
        "value": "02",
        "label": "Adıyaman"
      },
      {
        "value": "03",
        "label": "Afyonkarahisar"
      },
      {
        "value": "04",
        "label": "Ağrı"
      },
      {
        "value": "05",
        "label": "Amasya"
      },
      {
        "value": "06",
        "label": "Ankara"
      },
      {
        "value": "07",
        "label": "Antalya"
      },
      {
        "value": "08",
        "label": "Artvin"
      },
      {
        "value": "09",
        "label": "Aydın"
      },
      {
        "value": "10",
        "label": "Balıkesir"
      },
      {
        "value": "11",
        "label": "Bilecik"
      },
      {
        "value": "12",
        "label": "Bingöl"
      },
      {
        "value": "13",
        "label": "Bitlis"
      },
      {
        "value": "14",
        "label": "Bolu"
      },
      {
        "value": "15",
        "label": "Burdur"
      },
      {
        "value": "16",
        "label": "Bursa"
      },
      {
        "value": "17",
        "label": "Çanakkale"
      },
      {
        "value": "18",
        "label": "Çankırı"
      },
      {
        "value": "19",
        "label": "Çorum"
      },
      {
        "value": "20",
        "label": "Denizli"
      },
      {
        "value": "21",
        "label": "Diyarbakır"
      },
      {
        "value": "22",
        "label": "Edirne"
      },
      {
        "value": "23",
        "label": "Elazığ"
      },
      {
        "value": "24",
        "label": "Erzincan"
      },
      {
        "value": "25",
        "label": "Erzurum"
      },
      {
        "value": "26",
        "label": "Eskişehir"
      },
      {
        "value": "27",
        "label": "Gaziantep"
      },
      {
        "value": "28",
        "label": "Giresun"
      },
      {
        "value": "29",
        "label": "Gümüşhane"
      },
      {
        "value": "30",
        "label": "Hakkâri"
      },
      {
        "value": "31",
        "label": "Hatay"
      },
      {
        "value": "32",
        "label": "Isparta"
      },
      {
        "value": "33",
        "label": "Mersin"
      },
      {
        "value": "34",
        "label": "İstanbul"
      },
      {
        "value": "35",
        "label": "İzmir"
      },
      {
        "value": "36",
        "label": "Kars"
      },
      {
        "value": "37",
        "label": "Kastamonu"
      },
      {
        "value": "38",
        "label": "Kayseri"
      },
      {
        "value": "39",
        "label": "Kırklareli"
      },
      {
        "value": "40",
        "label": "Kırşehir"
      },
      {
        "value": "41",
        "label": "Kocaeli"
      },
      {
        "value": "42",
        "label": "Konya"
      },
      {
        "value": "43",
        "label": "Kütahya"
      },
      {
        "value": "44",
        "label": "Malatya"
      },
      {
        "value": "45",
        "label": "Manisa"
      },
      {
        "value": "46",
        "label": "Kahramanmaraş"
      },
      {
        "value": "47",
        "label": "Mardin"
      },
      {
        "value": "48",
        "label": "Muğla"
      },
      {
        "value": "49",
        "label": "Muş"
      },
      {
        "value": "50",
        "label": "Nevşehir"
      },
      {
        "value": "51",
        "label": "Niğde"
      },
      {
        "value": "52",
        "label": "Ordu"
      },
      {
        "value": "53",
        "label": "Rize"
      },
      {
        "value": "54",
        "label": "Sakarya"
      },
      {
        "value": "55",
        "label": "Samsun"
      },
      {
        "value": "56",
        "label": "Siirt"
      },
      {
        "value": "57",
        "label": "Sinop"
      },
      {
        "value": "58",
        "label": "Sivas"
      },
      {
        "value": "59",
        "label": "Tekirdağ"
      },
      {
        "value": "60",
        "label": "Tokat"
      },
      {
        "value": "61",
        "label": "Trabzon"
      },
      {
        "value": "62",
        "label": "Tunceli"
      },
      {
        "value": "63",
        "label": "Şanlıurfa"
      },
      {
        "value": "64",
        "label": "Uşak"
      },
      {
        "value": "65",
        "label": "Van"
      },
      {
        "value": "66",
        "label": "Yozgat"
      },
      {
        "value": "67",
        "label": "Zonguldak"
      },
      {
        "value": "68",
        "label": "Aksaray"
      },
      {
        "value": "69",
        "label": "Bayburt"
      },
      {
        "value": "70",
        "label": "Karaman"
      },
      {
        "value": "71",
        "label": "Kırıkkale"
      },
      {
        "value": "72",
        "label": "Batman"
      },
      {
        "value": "73",
        "label": "Şırnak"
      },
      {
        "value": "74",
        "label": "Bartın"
      },
      {
        "value": "75",
        "label": "Ardahan"
      },
      {
        "value": "76",
        "label": "Iğdır"
      },
      {
        "value": "77",
        "label": "Yalova"
      },
      {
        "value": "78",
        "label": "Karabük"
      },
      {
        "value": "79",
        "label": "Kilis"
      },
      {
        "value": "80",
        "label": "Osmaniye"
      },
      {
        "value": "81",
        "label": "Düzce"
      }
    ]
  },
  {
    "value": "TT",
    "label": "Trinidad and Tobago",
    "states": [
      {
        "value": "ARI",
        "label": "Arima"
      },
      {
        "value": "CHA",
        "label": "Chaguanas"
      },
      {
        "value": "CTT",
        "label": "Couva-Tabaquite-Talparo"
      },
      {
        "value": "DMN",
        "label": "Diego Martin"
      },
      {
        "value": "MRC",
        "label": "Mayaro-Rio Claro"
      },
      {
        "value": "PED",
        "label": "Penal-Debe"
      },
      {
        "value": "POS",
        "label": "Port of Spain"
      },
      {
        "value": "PRT",
        "label": "Princes Town"
      },
      {
        "value": "PTF",
        "label": "Point Fortin"
      },
      {
        "value": "SFO",
        "label": "San Fernando"
      },
      {
        "value": "SGE",
        "label": "Sangre Grande"
      },
      {
        "value": "SIP",
        "label": "Siparia"
      },
      {
        "value": "SJL",
        "label": "San Juan-Laventille"
      },
      {
        "value": "TOB",
        "label": "Tobago"
      },
      {
        "value": "TUP",
        "label": "Tunapuna-Piarco"
      }
    ]
  },
  {
    "value": "TV",
    "label": "Tuvalu",
    "states": [
      {
        "value": "FUN",
        "label": "Funafuti"
      },
      {
        "value": "NIT",
        "label": "Niutao"
      },
      {
        "value": "NKF",
        "label": "Nukufetau"
      },
      {
        "value": "NKL",
        "label": "Nukulaelae"
      },
      {
        "value": "NMA",
        "label": "Nanumea"
      },
      {
        "value": "NMG",
        "label": "Nanumaga"
      },
      {
        "value": "NUI",
        "label": "Nui"
      },
      {
        "value": "VAI",
        "label": "Vaitupu"
      }
    ]
  },
  {
    "value": "TW",
    "label": "Chinese Taipei",
    "states": [
      {
        "value": "CHA",
        "label": "Changhua"
      },
      {
        "value": "CYQ",
        "label": "Chiayi"
      },
      {
        "value": "HSZ",
        "label": "Hsinchu"
      },
      {
        "value": "HUA",
        "label": "Hualien"
      },
      {
        "value": "ILA",
        "label": "Yilan"
      },
      {
        "value": "KEE",
        "label": "Keelung"
      },
      {
        "value": "KHH",
        "label": "Kaohsiung"
      },
      {
        "value": "KIN",
        "label": "Kinmen"
      },
      {
        "value": "LIE",
        "label": "Lienchiang"
      },
      {
        "value": "MIA",
        "label": "Miaoli"
      },
      {
        "value": "NAN",
        "label": "Nantou"
      },
      {
        "value": "NWT",
        "label": "New Taipei"
      },
      {
        "value": "PEN",
        "label": "Penghu"
      },
      {
        "value": "PIF",
        "label": "Pingtung"
      },
      {
        "value": "TAO",
        "label": "Taoyuan"
      },
      {
        "value": "TNN",
        "label": "Tainan"
      },
      {
        "value": "TPE",
        "label": "Taipei"
      },
      {
        "value": "TTT",
        "label": "Taitung"
      },
      {
        "value": "TXG",
        "label": "Taichung"
      },
      {
        "value": "YUN",
        "label": "Yunlin"
      }
    ]
  },
  {
    "value": "TZ",
    "label": "Tanzania, United Republic of",
    "states": [
      {
        "value": "01",
        "label": "Arusha"
      },
      {
        "value": "02",
        "label": "Dar es Salaam"
      },
      {
        "value": "03",
        "label": "Dodoma"
      },
      {
        "value": "04",
        "label": "Iringa"
      },
      {
        "value": "05",
        "label": "Kagera"
      },
      {
        "value": "06",
        "label": "Pemba North"
      },
      {
        "value": "07",
        "label": "Zanzibar North"
      },
      {
        "value": "08",
        "label": "Kigoma"
      },
      {
        "value": "09",
        "label": "Kilimanjaro"
      },
      {
        "value": "10",
        "label": "Pemba South"
      },
      {
        "value": "11",
        "label": "Zanzibar South"
      },
      {
        "value": "12",
        "label": "Lindi"
      },
      {
        "value": "13",
        "label": "Mara"
      },
      {
        "value": "14",
        "label": "Mbeya"
      },
      {
        "value": "15",
        "label": "Zanzibar West"
      },
      {
        "value": "16",
        "label": "Morogoro"
      },
      {
        "value": "17",
        "label": "Mtwara"
      },
      {
        "value": "18",
        "label": "Mwanza"
      },
      {
        "value": "19",
        "label": "Coast"
      },
      {
        "value": "20",
        "label": "Rukwa"
      },
      {
        "value": "21",
        "label": "Ruvuma"
      },
      {
        "value": "22",
        "label": "Shinyanga"
      },
      {
        "value": "23",
        "label": "Singida"
      },
      {
        "value": "24",
        "label": "Tabora"
      },
      {
        "value": "25",
        "label": "Tanga"
      },
      {
        "value": "26",
        "label": "Manyara"
      },
      {
        "value": "27",
        "label": "Geita"
      },
      {
        "value": "28",
        "label": "Katavi"
      },
      {
        "value": "29",
        "label": "Njombe"
      },
      {
        "value": "30",
        "label": "Simiyu"
      },
      {
        "value": "31",
        "label": "Songwe"
      }
    ]
  },
  {
    "value": "UA",
    "label": "Ukraine",
    "states": [
      {
        "value": "05",
        "label": "Vinnytska oblast"
      },
      {
        "value": "07",
        "label": "Volynska oblast"
      },
      {
        "value": "09",
        "label": "Luhanska oblast"
      },
      {
        "value": "12",
        "label": "Dnipropetrovska oblast"
      },
      {
        "value": "14",
        "label": "Donetska oblast"
      },
      {
        "value": "18",
        "label": "Zhytomyrska oblast"
      },
      {
        "value": "21",
        "label": "Zakarpatska oblast"
      },
      {
        "value": "23",
        "label": "Zaporizka oblast"
      },
      {
        "value": "26",
        "label": "Ivano-Frankivska oblast"
      },
      {
        "value": "30",
        "label": "Kyiv"
      },
      {
        "value": "32",
        "label": "Kyivska oblast"
      },
      {
        "value": "35",
        "label": "Kirovohradska oblast"
      },
      {
        "value": "40",
        "label": "Sevastopol"
      },
      {
        "value": "43",
        "label": "Avtonomna Respublika Krym"
      },
      {
        "value": "46",
        "label": "Lvivska oblast"
      },
      {
        "value": "48",
        "label": "Mykolaivska oblast"
      },
      {
        "value": "51",
        "label": "Odeska oblast"
      },
      {
        "value": "53",
        "label": "Poltavska oblast"
      },
      {
        "value": "56",
        "label": "Rivnenska oblast"
      },
      {
        "value": "59",
        "label": "Sumska oblast"
      },
      {
        "value": "61",
        "label": "Ternopilska oblast"
      },
      {
        "value": "63",
        "label": "Kharkivska oblast"
      },
      {
        "value": "65",
        "label": "Khersonska oblast"
      },
      {
        "value": "68",
        "label": "Khmelnytska oblast"
      },
      {
        "value": "71",
        "label": "Cherkaska oblast"
      },
      {
        "value": "74",
        "label": "Chernihivska oblast"
      },
      {
        "value": "77",
        "label": "Chernivetska oblast"
      }
    ]
  },
  {
    "value": "UG",
    "label": "Uganda",
    "states": [
      {
        "value": "101",
        "label": "Kalangala"
      },
      {
        "value": "102",
        "label": "Kampala"
      },
      {
        "value": "103",
        "label": "Kiboga"
      },
      {
        "value": "104",
        "label": "Luwero"
      },
      {
        "value": "105",
        "label": "Masaka"
      },
      {
        "value": "106",
        "label": "Mpigi"
      },
      {
        "value": "107",
        "label": "Mubende"
      },
      {
        "value": "108",
        "label": "Mukono"
      },
      {
        "value": "109",
        "label": "Nakasongola"
      },
      {
        "value": "110",
        "label": "Rakai"
      },
      {
        "value": "111",
        "label": "Sembabule"
      },
      {
        "value": "112",
        "label": "Kayunga"
      },
      {
        "value": "113",
        "label": "Wakiso"
      },
      {
        "value": "114",
        "label": "Lyantonde"
      },
      {
        "value": "115",
        "label": "Mityana"
      },
      {
        "value": "116",
        "label": "Nakaseke"
      },
      {
        "value": "117",
        "label": "Buikwe"
      },
      {
        "value": "118",
        "label": "Bukomansibi"
      },
      {
        "value": "119",
        "label": "Butambala"
      },
      {
        "value": "120",
        "label": "Buvuma"
      },
      {
        "value": "121",
        "label": "Gomba"
      },
      {
        "value": "122",
        "label": "Kalungu"
      },
      {
        "value": "123",
        "label": "Kyankwanzi"
      },
      {
        "value": "124",
        "label": "Lwengo"
      },
      {
        "value": "125",
        "label": "Kyotera"
      },
      {
        "value": "126",
        "label": "Kasanda"
      },
      {
        "value": "201",
        "label": "Bugiri"
      },
      {
        "value": "202",
        "label": "Busia"
      },
      {
        "value": "203",
        "label": "Iganga"
      },
      {
        "value": "204",
        "label": "Jinja"
      },
      {
        "value": "205",
        "label": "Kamuli"
      },
      {
        "value": "206",
        "label": "Kapchorwa"
      },
      {
        "value": "207",
        "label": "Katakwi"
      },
      {
        "value": "208",
        "label": "Kumi"
      },
      {
        "value": "209",
        "label": "Mbale"
      },
      {
        "value": "210",
        "label": "Pallisa"
      },
      {
        "value": "211",
        "label": "Soroti"
      },
      {
        "value": "212",
        "label": "Tororo"
      },
      {
        "value": "213",
        "label": "Kaberamaido"
      },
      {
        "value": "214",
        "label": "Mayuge"
      },
      {
        "value": "215",
        "label": "Sironko"
      },
      {
        "value": "216",
        "label": "Amuria"
      },
      {
        "value": "217",
        "label": "Budaka"
      },
      {
        "value": "218",
        "label": "Bududa"
      },
      {
        "value": "219",
        "label": "Bukedea"
      },
      {
        "value": "220",
        "label": "Bukwo"
      },
      {
        "value": "221",
        "label": "Butaleja"
      },
      {
        "value": "222",
        "label": "Kaliro"
      },
      {
        "value": "223",
        "label": "Manafwa"
      },
      {
        "value": "224",
        "label": "Namutumba"
      },
      {
        "value": "225",
        "label": "Bulambuli"
      },
      {
        "value": "226",
        "label": "Buyende"
      },
      {
        "value": "227",
        "label": "Kibuku"
      },
      {
        "value": "228",
        "label": "Kween"
      },
      {
        "value": "229",
        "label": "Luuka"
      },
      {
        "value": "230",
        "label": "Namayingo"
      },
      {
        "value": "231",
        "label": "Ngora"
      },
      {
        "value": "232",
        "label": "Serere"
      },
      {
        "value": "233",
        "label": "Butebo"
      },
      {
        "value": "234",
        "label": "Namisindwa"
      },
      {
        "value": "235",
        "label": "Bugweri"
      },
      {
        "value": "236",
        "label": "Kapelebyong"
      },
      {
        "value": "237",
        "label": "Kalaki"
      },
      {
        "value": "301",
        "label": "Adjumani"
      },
      {
        "value": "302",
        "label": "Apac"
      },
      {
        "value": "303",
        "label": "Arua"
      },
      {
        "value": "304",
        "label": "Gulu"
      },
      {
        "value": "305",
        "label": "Kitgum"
      },
      {
        "value": "306",
        "label": "Kotido"
      },
      {
        "value": "307",
        "label": "Lira"
      },
      {
        "value": "308",
        "label": "Moroto"
      },
      {
        "value": "309",
        "label": "Moyo"
      },
      {
        "value": "310",
        "label": "Nebbi"
      },
      {
        "value": "311",
        "label": "Nakapiripirit"
      },
      {
        "value": "312",
        "label": "Pader"
      },
      {
        "value": "313",
        "label": "Yumbe"
      },
      {
        "value": "314",
        "label": "Abim"
      },
      {
        "value": "315",
        "label": "Amolatar"
      },
      {
        "value": "316",
        "label": "Amuru"
      },
      {
        "value": "317",
        "label": "Dokolo"
      },
      {
        "value": "318",
        "label": "Kaabong"
      },
      {
        "value": "319",
        "label": "Koboko"
      },
      {
        "value": "320",
        "label": "Maracha"
      },
      {
        "value": "321",
        "label": "Oyam"
      },
      {
        "value": "322",
        "label": "Agago"
      },
      {
        "value": "323",
        "label": "Alebtong"
      },
      {
        "value": "324",
        "label": "Amudat"
      },
      {
        "value": "325",
        "label": "Kole"
      },
      {
        "value": "326",
        "label": "Lamwo"
      },
      {
        "value": "327",
        "label": "Napak"
      },
      {
        "value": "328",
        "label": "Nwoya"
      },
      {
        "value": "329",
        "label": "Otuke"
      },
      {
        "value": "330",
        "label": "Zombo"
      },
      {
        "value": "331",
        "label": "Omoro"
      },
      {
        "value": "332",
        "label": "Pakwach"
      },
      {
        "value": "333",
        "label": "Kwania"
      },
      {
        "value": "334",
        "label": "Nabilatuk"
      },
      {
        "value": "335",
        "label": "Karenga"
      },
      {
        "value": "336",
        "label": "Madi-Okollo"
      },
      {
        "value": "337",
        "label": "Obongi"
      },
      {
        "value": "401",
        "label": "Bundibugyo"
      },
      {
        "value": "402",
        "label": "Bushenyi"
      },
      {
        "value": "403",
        "label": "Hoima"
      },
      {
        "value": "404",
        "label": "Kabale"
      },
      {
        "value": "405",
        "label": "Kabarole"
      },
      {
        "value": "406",
        "label": "Kasese"
      },
      {
        "value": "407",
        "label": "Kibaale"
      },
      {
        "value": "408",
        "label": "Kisoro"
      },
      {
        "value": "409",
        "label": "Masindi"
      },
      {
        "value": "410",
        "label": "Mbarara"
      },
      {
        "value": "411",
        "label": "Ntungamo"
      },
      {
        "value": "412",
        "label": "Rukungiri"
      },
      {
        "value": "413",
        "label": "Kamwenge"
      },
      {
        "value": "414",
        "label": "Kanungu"
      },
      {
        "value": "415",
        "label": "Kyenjojo"
      },
      {
        "value": "416",
        "label": "Buliisa"
      },
      {
        "value": "417",
        "label": "Ibanda"
      },
      {
        "value": "418",
        "label": "Isingiro"
      },
      {
        "value": "419",
        "label": "Kiruhura"
      },
      {
        "value": "420",
        "label": "Buhweju"
      },
      {
        "value": "421",
        "label": "Kiryandongo"
      },
      {
        "value": "422",
        "label": "Kyegegwa"
      },
      {
        "value": "423",
        "label": "Mitooma"
      },
      {
        "value": "424",
        "label": "Ntoroko"
      },
      {
        "value": "425",
        "label": "Rubirizi"
      },
      {
        "value": "426",
        "label": "Sheema"
      },
      {
        "value": "427",
        "label": "Kagadi"
      },
      {
        "value": "428",
        "label": "Kakumiro"
      },
      {
        "value": "429",
        "label": "Rubanda"
      },
      {
        "value": "430",
        "label": "Bunyangabu"
      },
      {
        "value": "431",
        "label": "Rukiga"
      },
      {
        "value": "432",
        "label": "Kikuube"
      },
      {
        "value": "433",
        "label": "Kazo"
      },
      {
        "value": "434",
        "label": "Kitagwenda"
      },
      {
        "value": "435",
        "label": "Rwampara"
      },
      {
        "value": "C",
        "label": "Central"
      },
      {
        "value": "E",
        "label": "Eastern"
      },
      {
        "value": "N",
        "label": "Northern"
      },
      {
        "value": "W",
        "label": "Western"
      }
    ]
  },
  {
    "value": "US",
    "label": "United states",
    "states": [
      {
        "value": "AA",
        "label": "Armed Forces Americas"
      },
      {
        "value": "AE",
        "label": "Armed Forces Europe"
      },
      {
        "value": "AK",
        "label": "Alaska"
      },
      {
        "value": "AL",
        "label": "Alabama"
      },
      {
        "value": "AP",
        "label": "Armed Forces Pacific"
      },
      {
        "value": "AR",
        "label": "Arkansas"
      },
      {
        "value": "AS",
        "label": "American Samoa"
      },
      {
        "value": "AZ",
        "label": "Arizona"
      },
      {
        "value": "CA",
        "label": "California"
      },
      {
        "value": "CO",
        "label": "Colorado"
      },
      {
        "value": "CT",
        "label": "Connecticut"
      },
      {
        "value": "DC",
        "label": "District of Columbia"
      },
      {
        "value": "DE",
        "label": "Delaware"
      },
      {
        "value": "FL",
        "label": "Florida"
      },
      {
        "value": "FM",
        "label": "Federated Micronesia"
      },
      {
        "value": "GA",
        "label": "Georgia"
      },
      {
        "value": "GU",
        "label": "Guam"
      },
      {
        "value": "HI",
        "label": "Hawaii"
      },
      {
        "value": "IA",
        "label": "Iowa"
      },
      {
        "value": "ID",
        "label": "Idaho"
      },
      {
        "value": "IL",
        "label": "Illinois"
      },
      {
        "value": "IN",
        "label": "Indiana"
      },
      {
        "value": "KS",
        "label": "Kansas"
      },
      {
        "value": "KY",
        "label": "Kentucky"
      },
      {
        "value": "LA",
        "label": "Louisiana"
      },
      {
        "value": "MA",
        "label": "Massachusetts"
      },
      {
        "value": "MD",
        "label": "Maryland"
      },
      {
        "value": "ME",
        "label": "Maine"
      },
      {
        "value": "MH",
        "label": "Marshall Islands"
      },
      {
        "value": "MI",
        "label": "Michigan"
      },
      {
        "value": "MN",
        "label": "Minnesota"
      },
      {
        "value": "MO",
        "label": "Missouri"
      },
      {
        "value": "MP",
        "label": "Northern Mariana Islands"
      },
      {
        "value": "MS",
        "label": "Mississippi"
      },
      {
        "value": "MT",
        "label": "Montana"
      },
      {
        "value": "NC",
        "label": "North Carolina"
      },
      {
        "value": "ND",
        "label": "North Dakota"
      },
      {
        "value": "NE",
        "label": "Nebraska"
      },
      {
        "value": "NH",
        "label": "New Hampshire"
      },
      {
        "value": "NJ",
        "label": "New Jersey"
      },
      {
        "value": "NM",
        "label": "New Mexico"
      },
      {
        "value": "NV",
        "label": "Nevada"
      },
      {
        "value": "NY",
        "label": "New York"
      },
      {
        "value": "OH",
        "label": "Ohio"
      },
      {
        "value": "OK",
        "label": "Oklahoma"
      },
      {
        "value": "OR",
        "label": "Oregon"
      },
      {
        "value": "PA",
        "label": "Pennsylvania"
      },
      {
        "value": "PR",
        "label": "Puerto Rico"
      },
      {
        "value": "PW",
        "label": "Palau"
      },
      {
        "value": "RI",
        "label": "Rhode Island"
      },
      {
        "value": "SC",
        "label": "South Carolina"
      },
      {
        "value": "SD",
        "label": "South Dakota"
      },
      {
        "value": "TN",
        "label": "Tennessee"
      },
      {
        "value": "TX",
        "label": "Texas"
      },
      {
        "value": "UM",
        "label": "United states Minor Outlying Islands"
      },
      {
        "value": "UT",
        "label": "Utah"
      },
      {
        "value": "VA",
        "label": "Virginia"
      },
      {
        "value": "VI",
        "label": "US Virgin Islands"
      },
      {
        "value": "VT",
        "label": "Vermont"
      },
      {
        "value": "WA",
        "label": "Washington"
      },
      {
        "value": "WI",
        "label": "Wisconsin"
      },
      {
        "value": "WV",
        "label": "West Virginia"
      },
      {
        "value": "WY",
        "label": "Wyoming"
      }
    ]
  },
  {
    "value": "UY",
    "label": "Uruguay",
    "states": [
      {
        "value": "AR",
        "label": "Artigas"
      },
      {
        "value": "CA",
        "label": "Canelones"
      },
      {
        "value": "CL",
        "label": "Cerro Largo"
      },
      {
        "value": "CO",
        "label": "Colonia"
      },
      {
        "value": "DU",
        "label": "Durazno"
      },
      {
        "value": "FD",
        "label": "Florida"
      },
      {
        "value": "FS",
        "label": "Flores"
      },
      {
        "value": "LA",
        "label": "Lavalleja"
      },
      {
        "value": "MA",
        "label": "Maldonado"
      },
      {
        "value": "MO",
        "label": "Montevideo"
      },
      {
        "value": "PA",
        "label": "Paysandú"
      },
      {
        "value": "RN",
        "label": "Río Negro"
      },
      {
        "value": "RO",
        "label": "Rocha"
      },
      {
        "value": "RV",
        "label": "Rivera"
      },
      {
        "value": "SA",
        "label": "Salto"
      },
      {
        "value": "SJ",
        "label": "San José"
      },
      {
        "value": "SO",
        "label": "Soriano"
      },
      {
        "value": "TA",
        "label": "Tacuarembó"
      },
      {
        "value": "TT",
        "label": "Treinta y Tres"
      }
    ]
  },
  {
    "value": "UZ",
    "label": "Uzbekistan",
    "states": [
      {
        "value": "AN",
        "label": "Andijon"
      },
      {
        "value": "BU",
        "label": "Buxoro"
      },
      {
        "value": "FA",
        "label": "Farg‘ona"
      },
      {
        "value": "JI",
        "label": "Jizzax"
      },
      {
        "value": "NG",
        "label": "Namangan"
      },
      {
        "value": "NW",
        "label": "Navoiy"
      },
      {
        "value": "QA",
        "label": "Qashqadaryo"
      },
      {
        "value": "QR",
        "label": "Qoraqalpog‘iston Respublikasi"
      },
      {
        "value": "SA",
        "label": "Samarqand"
      },
      {
        "value": "SI",
        "label": "Sirdaryo"
      },
      {
        "value": "SU",
        "label": "Surxondaryo"
      },
      {
        "value": "TO",
        "label": "Toshkent"
      },
      {
        "value": "XO",
        "label": "Xorazm"
      }
    ]
  },
  {
    "value": "VA",
    "label": "Holy See (Vatican City State)",
    "states": []
  },
  {
    "value": "VC",
    "label": "Saint Vincent and the Grenadines",
    "states": [
      {
        "value": "01",
        "label": "Charlotte"
      },
      {
        "value": "02",
        "label": "Saint Andrew"
      },
      {
        "value": "03",
        "label": "Saint David"
      },
      {
        "value": "04",
        "label": "Saint George"
      },
      {
        "value": "05",
        "label": "Saint Patrick"
      },
      {
        "value": "06",
        "label": "Grenadines"
      }
    ]
  },
  {
    "value": "VE",
    "label": "Venezuela, Bolivarian Republic of",
    "states": [
      {
        "value": "A",
        "label": "Distrito Capital"
      },
      {
        "value": "B",
        "label": "Anzoátegui"
      },
      {
        "value": "C",
        "label": "Apure"
      },
      {
        "value": "D",
        "label": "Aragua"
      },
      {
        "value": "E",
        "label": "Barinas"
      },
      {
        "value": "F",
        "label": "Bolívar"
      },
      {
        "value": "G",
        "label": "Carabobo"
      },
      {
        "value": "H",
        "label": "Cojedes"
      },
      {
        "value": "I",
        "label": "Falcón"
      },
      {
        "value": "J",
        "label": "Guárico"
      },
      {
        "value": "K",
        "label": "Lara"
      },
      {
        "value": "L",
        "label": "Mérida"
      },
      {
        "value": "M",
        "label": "Miranda"
      },
      {
        "value": "N",
        "label": "Monagas"
      },
      {
        "value": "O",
        "label": "Nueva Esparta"
      },
      {
        "value": "P",
        "label": "Portuguesa"
      },
      {
        "value": "R",
        "label": "Sucre"
      },
      {
        "value": "S",
        "label": "Táchira"
      },
      {
        "value": "T",
        "label": "Trujillo"
      },
      {
        "value": "U",
        "label": "Yaracuy"
      },
      {
        "value": "V",
        "label": "Zulia"
      },
      {
        "value": "W",
        "label": "Dependencias Federales"
      },
      {
        "value": "X",
        "label": "La Guaira"
      },
      {
        "value": "Y",
        "label": "Delta Amacuro"
      },
      {
        "value": "Z",
        "label": "Amazonas"
      }
    ]
  },
  {
    "value": "VG",
    "label": "Virgin Islands, British",
    "states": []
  },
  {
    "value": "VN",
    "label": "Viet Nam",
    "states": [
      {
        "value": "01",
        "label": "Lai Châu"
      },
      {
        "value": "02",
        "label": "Lào Cai"
      },
      {
        "value": "03",
        "label": "Hà Giang"
      },
      {
        "value": "04",
        "label": "Cao Bằng"
      },
      {
        "value": "05",
        "label": "Sơn La"
      },
      {
        "value": "06",
        "label": "Yên Bái"
      },
      {
        "value": "07",
        "label": "Tuyên Quang"
      },
      {
        "value": "09",
        "label": "Lạng Sơn"
      },
      {
        "value": "13",
        "label": "Quảng Ninh"
      },
      {
        "value": "14",
        "label": "Hòa Bình"
      },
      {
        "value": "18",
        "label": "Ninh Bình"
      },
      {
        "value": "20",
        "label": "Thái Bình"
      },
      {
        "value": "21",
        "label": "Thanh Hóa"
      },
      {
        "value": "22",
        "label": "Nghệ An"
      },
      {
        "value": "23",
        "label": "Hà Tĩnh"
      },
      {
        "value": "24",
        "label": "Quảng Bình"
      },
      {
        "value": "25",
        "label": "Quảng Trị"
      },
      {
        "value": "26",
        "label": "Thừa Thiên-Huế"
      },
      {
        "value": "27",
        "label": "Quảng Nam"
      },
      {
        "value": "28",
        "label": "Kon Tum"
      },
      {
        "value": "29",
        "label": "Quảng Ngãi"
      },
      {
        "value": "30",
        "label": "Gia Lai"
      },
      {
        "value": "31",
        "label": "Bình Định"
      },
      {
        "value": "32",
        "label": "Phú Yên"
      },
      {
        "value": "33",
        "label": "Đắk Lắk"
      },
      {
        "value": "34",
        "label": "Khánh Hòa"
      },
      {
        "value": "35",
        "label": "Lâm Đồng"
      },
      {
        "value": "36",
        "label": "Ninh Thuận"
      },
      {
        "value": "37",
        "label": "Tây Ninh"
      },
      {
        "value": "39",
        "label": "Đồng Nai"
      },
      {
        "value": "40",
        "label": "Bình Thuận"
      },
      {
        "value": "41",
        "label": "Long An"
      },
      {
        "value": "43",
        "label": "Bà Rịa - Vũng Tàu"
      },
      {
        "value": "44",
        "label": "An Giang"
      },
      {
        "value": "45",
        "label": "Đồng Tháp"
      },
      {
        "value": "46",
        "label": "Tiền Giang"
      },
      {
        "value": "47",
        "label": "Kiến Giang"
      },
      {
        "value": "49",
        "label": "Vĩnh Long"
      },
      {
        "value": "50",
        "label": "Bến Tre"
      },
      {
        "value": "51",
        "label": "Trà Vinh"
      },
      {
        "value": "52",
        "label": "Sóc Trăng"
      },
      {
        "value": "53",
        "label": "Bắc Kạn"
      },
      {
        "value": "54",
        "label": "Bắc Giang"
      },
      {
        "value": "55",
        "label": "Bạc Liêu"
      },
      {
        "value": "56",
        "label": "Bắc Ninh"
      },
      {
        "value": "57",
        "label": "Bình Dương"
      },
      {
        "value": "58",
        "label": "Bình Phước"
      },
      {
        "value": "59",
        "label": "Cà Mau"
      },
      {
        "value": "61",
        "label": "Hải Dương"
      },
      {
        "value": "63",
        "label": "Hà Nam"
      },
      {
        "value": "66",
        "label": "Hưng Yên"
      },
      {
        "value": "67",
        "label": "Nam Định"
      },
      {
        "value": "68",
        "label": "Phú Thọ"
      },
      {
        "value": "69",
        "label": "Thái Nguyên"
      },
      {
        "value": "70",
        "label": "Vĩnh Phúc"
      },
      {
        "value": "71",
        "label": "Điện Biên"
      },
      {
        "value": "72",
        "label": "Đắk Nông"
      },
      {
        "value": "73",
        "label": "Hậu Giang"
      },
      {
        "value": "CT",
        "label": "Cần Thơ"
      },
      {
        "value": "DN",
        "label": "Đà Nẵng"
      },
      {
        "value": "HN",
        "label": "Hà Nội"
      },
      {
        "value": "HP",
        "label": "Hải Phòng"
      },
      {
        "value": "SG",
        "label": "Sai Gon"
      }
    ]
  },
  {
    "value": "VU",
    "label": "Vanuatu",
    "states": [
      {
        "value": "MAP",
        "label": "Malampa"
      },
      {
        "value": "PAM",
        "label": "Pénama"
      },
      {
        "value": "SAM",
        "label": "Sanma"
      },
      {
        "value": "SEE",
        "label": "Shéfa"
      },
      {
        "value": "TAE",
        "label": "Taféa"
      },
      {
        "value": "TOB",
        "label": "Torba"
      }
    ]
  },
  {
    "value": "WF",
    "label": "Wallis and Futuna",
    "states": [
      {
        "value": "AL",
        "label": "Alo"
      },
      {
        "value": "SG",
        "label": "Sigave"
      },
      {
        "value": "UV",
        "label": "Uvea"
      }
    ]
  },
  {
    "value": "WS",
    "label": "Samoa",
    "states": [
      {
        "value": "AA",
        "label": "A'ana"
      },
      {
        "value": "AL",
        "label": "Aiga-i-le-Tai"
      },
      {
        "value": "AT",
        "label": "Atua"
      },
      {
        "value": "FA",
        "label": "Fa'asaleleaga"
      },
      {
        "value": "GE",
        "label": "Gaga'emauga"
      },
      {
        "value": "GI",
        "label": "Gagaifomauga"
      },
      {
        "value": "PA",
        "label": "Palauli"
      },
      {
        "value": "SA",
        "label": "Satupa'itea"
      },
      {
        "value": "TU",
        "label": "Tuamasaga"
      },
      {
        "value": "VF",
        "label": "Va'a-o-Fonoti"
      },
      {
        "value": "VS",
        "label": "Vaisigano"
      }
    ]
  },
  {
    "value": "YE",
    "label": "Yemen",
    "states": [
      {
        "value": "AB",
        "label": "Abyan"
      },
      {
        "value": "AD",
        "label": "‘Adan"
      },
      {
        "value": "AM",
        "label": "‘Amrān"
      },
      {
        "value": "BA",
        "label": "Al Bayḑā’"
      },
      {
        "value": "DA",
        "label": "Aḑ Ḑāli‘"
      },
      {
        "value": "DH",
        "label": "Dhamār"
      },
      {
        "value": "HD",
        "label": "Ḩaḑramawt"
      },
      {
        "value": "HJ",
        "label": "Ḩajjah"
      },
      {
        "value": "HU",
        "label": "Al Ḩudaydah"
      },
      {
        "value": "IB",
        "label": "Ibb"
      },
      {
        "value": "JA",
        "label": "Al Jawf"
      },
      {
        "value": "LA",
        "label": "Laḩij"
      },
      {
        "value": "MA",
        "label": "Ma’rib"
      },
      {
        "value": "MR",
        "label": "Al Mahrah"
      },
      {
        "value": "MW",
        "label": "Al Maḩwīt"
      },
      {
        "value": "RA",
        "label": "Raymah"
      },
      {
        "value": "SA",
        "label": "Amānat al ‘Āşimah"
      },
      {
        "value": "SD",
        "label": "Şāʻdah"
      },
      {
        "value": "SH",
        "label": "Shabwah"
      },
      {
        "value": "SN",
        "label": "Şanʻā’"
      },
      {
        "value": "SU",
        "label": "Arkhabīl Suquţrá"
      },
      {
        "value": "TA",
        "label": "Tāʻizz"
      }
    ]
  },
  {
    "value": "YT",
    "label": "Mayotte",
    "states": []
  },
  {
    "value": "ZA",
    "label": "South Africa",
    "states": [
      {
        "value": "EC",
        "label": "Eastern Cape"
      },
      {
        "value": "FS",
        "label": "Free State"
      },
      {
        "value": "GP",
        "label": "Gauteng"
      },
      {
        "value": "KZN",
        "label": "Kwazulu-Natal"
      },
      {
        "value": "LP",
        "label": "Limpopo"
      },
      {
        "value": "MP",
        "label": "Mpumalanga"
      },
      {
        "value": "NC",
        "label": "Northern Cape"
      },
      {
        "value": "NW",
        "label": "North-West"
      },
      {
        "value": "WC",
        "label": "Western Cape"
      }
    ]
  },
  {
    "value": "ZM",
    "label": "Zambia",
    "states": [
      {
        "value": "01",
        "label": "Western"
      },
      {
        "value": "02",
        "label": "Central"
      },
      {
        "value": "03",
        "label": "Eastern"
      },
      {
        "value": "04",
        "label": "Luapula"
      },
      {
        "value": "05",
        "label": "Northern"
      },
      {
        "value": "06",
        "label": "North-Western"
      },
      {
        "value": "07",
        "label": "Southern"
      },
      {
        "value": "08",
        "label": "Copperbelt"
      },
      {
        "value": "09",
        "label": "Lusaka"
      },
      {
        "value": "10",
        "label": "Muchinga"
      }
    ]
  },
  {
    "value": "ZW",
    "label": "Zimbabwe",
    "states": [
      {
        "value": "BU",
        "label": "Bulawayo"
      },
      {
        "value": "HA",
        "label": "Harare"
      },
      {
        "value": "MA",
        "label": "Manicaland"
      },
      {
        "value": "MC",
        "label": "Mashonaland Central"
      },
      {
        "value": "ME",
        "label": "Mashonaland East"
      },
      {
        "value": "MI",
        "label": "Midlands"
      },
      {
        "value": "MN",
        "label": "Matabeleland North"
      },
      {
        "value": "MS",
        "label": "Matabeleland South"
      },
      {
        "value": "MV",
        "label": "Masvingo"
      },
      {
        "value": "MW",
        "label": "Mashonaland West"
      }
    ]
  }
,
        { label: 'Other', value: 'Other' }
    ];

    stateOptions = [];

    handleInputChange(event) {
    const fieldName = event.target.name;
    const fieldValue = event.target.value;
    this.formData = {
        ...this.formData,
        [fieldName]: fieldValue
    };
    if (this.errorMessage) {
        this.errorMessage = '';
    }
    if (fieldName === 'country') {
        this.handleCountryChange(event);
    }
}

handleCountryChange(event) {
    const selectedCountry = event.target.value;
    const country = this.countryOptions.find(c => c.value === selectedCountry);
    if (country && country.states && country.states.length > 0) {
        this.stateOptions = country.states.map(state => ({
            label: state.label,
            value: state.value
        }));
    } else {
        this.stateOptions = [];
    }

    const stateSelect = this.template.querySelector('select[name="state"]');
    if (stateSelect) {
        stateSelect.value = '';
    }
}

    handleReset() {
        this.formData = {
            name: '',
            corporateName: '',
            taxNumber: '',
            marketSegment: '',
            motivationType: '',
            customerType: '',
            email: '',
            phone: '',
            mobilePhone: '',
            fax: '',
            country: '',
            street: '',
            postalCode: '',
            city: '',
            state: '',
            requestComments: '',
            addressSearch: ''
        };
        // Forzar el reseteo visual de los selects y textarea
        const selects = this.template.querySelectorAll('select');
        selects.forEach(select => { select.value = ''; });
        const textareas = this.template.querySelectorAll('textarea');
        textareas.forEach(textarea => { textarea.value = ''; });
        // No ocultar el mensaje de éxito aquí, para Guest
        this.errorMessage = '';
        this.isSubmitting = false;
    }

    validateForm() {
        const requiredFields = ['name', 'corporateName', 'taxNumber', 'marketSegment', 'motivationType', 'customerType', 'email','country', 'street', 'city'];
        const missingFields = [];
        requiredFields.forEach(field => {
            if (!this.formData[field] || this.formData[field].trim() === '') {
                missingFields.push(field);
            }
        });
        if (missingFields.length > 0) {
            this.errorMessage = 'Please complete all required fields.';
            return false;
        }
        // Max length validation for name, corporateName, and street
        if (this.formData.name && this.formData.name.length > 60) {
            this.errorMessage = 'The Name field cannot exceed 60 characters.';
            return false;
        }
        if (this.formData.corporateName && this.formData.corporateName.length > 60) {
            this.errorMessage = 'The Corporate Name field cannot exceed 60 characters.';
            return false;
        }
        if (this.formData.street && this.formData.street.length > 60) {
            this.errorMessage = 'The Street field cannot exceed 60 characters.';
            return false;
        }
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(this.formData.email)) {
            this.errorMessage = 'Please enter a valid email address.';
            return false;
        }
        return true;
    }

    async handleSubmit() {
        if (!this.validateForm()) {
            return;
        }
        this.isSubmitting = true;
        this.errorMessage = '';
        try {
            const result = await createAccountRequest({ 
                requestData: this.formData 
            });
            if (result.success) {
                this.showSuccess = true;
                this.showToast('Success', 'Request submitted successfully', 'success');
                // Do not hide the success message immediately for Guest
                setTimeout(() => {
                    this.showSuccess = false;
                }, 4000);
                this.handleReset();
            } else {
                this.errorMessage = result.message || 'Error processing the request';
                this.showToast('Error', this.errorMessage, 'error');
            }
        } catch (error) {
            console.error('Error submitting form:', error);
            this.errorMessage = 'An unexpected error occurred. Please try again.';
            this.showToast('Error', this.errorMessage, 'error');
        } finally {
            this.isSubmitting = false;
        }
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}