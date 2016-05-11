/** 
 * Christophe Coenraets, http://coenraets.org
 */
package controller
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.events.PropertyChangeEvent;
	import mx.formatters.DateFormatter;
	import mx.messaging.ChannelSet;
	import mx.messaging.channels.AMFChannel;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	import spark.managers.PersistenceManager;
	
	import model.CheckInfo;
	
	 

	public class SensingFeed extends EventDispatcher
	{
		 
	 
		
		protected var timer:Timer;
		
	 
		
		private var datef:DateFormatter=new DateFormatter;
	 
		
		private var myAMF:AMFChannel=new AMFChannel();
		private var channelSet:ChannelSet=new ChannelSet();
		private var ro:RemoteObject = new RemoteObject();
		private  var serveraddress:PersistenceManager = new PersistenceManager();

		public function SensingFeed()
		{
			datef.formatString="YYYY/MM/DD JJ:NN:SS";
		 	if(serveraddress.load())
			{
				if(serveraddress.getProperty("serverAddr"))
				{
					 
					myAMF.url = serveraddress.getProperty("serverAddr") as String;
					channelSet.addChannel(myAMF); 
					
					ro.channelSet = channelSet;
					ro.destination = "GetCheckInfoService";
					ro.addEventListener(ResultEvent.RESULT,ds_resulted);
					ro.addEventListener(FaultEvent.FAULT,faultHandle);
					ro.getlist();	
				}
				else
				{ 
				}
			}
			else
			{
				myAMF.url="";
			}
			trace("SensingFeed()");
			
			
			
		}
		private  function  faultHandle(event:FaultEvent):void
		{ 
			trace("SensingFeed request error");
			trace(event.fault.faultString);
			trace(event.fault.faultDetail);
		}
		public function refresh():void{
			ro.getNewestSensings();	
		}
		
		private function property_change(event:Event):void{
			trace("ds property changed `````");
		}
		private function ds_resulted(event:ResultEvent):void{
			 
			for(var e:Object in event.result ){
			 	trace("got  the latest data");
				var st:CheckInfo= new CheckInfo();
				st.teacherName = event.result[e].teacherName;
				
				st.subjectName = event.result[e].courseName;
				st.checkTime=datef.format(event.result[e].gTime);
				
				st.ischeck=event.result[e].isWork;
				if(st.ischeck=="1")
				{
					st.ischeck="是";
				}
				else
				{
					st.ischeck="否";
				}
			    FlexGlobals.topLevelApplication.newestSensingList.addItemAt(st,0);
			}
		 
			
		}
	

	}
}