<cfcomponent>
<cfoutput>

<!--- 
 

ts={
	arrAmount:[
		// one time payment example
		{
			amount:2,
			label: "One Time Payment"
		},
		// subscription payment example
		{
			amount:2,
			label="Subscription Payment",
			frequency: 1, // ommitting this field or setting it to 0 disables the subscription feature for this payment option, 1 will collect a payment each subscriptionPeriod, 2+ will skip subscriptionPeriods (i.e. 2 is bimonthly, 3 is trimonthly etc)
			period: 'M', // M = month | Y = year | D = day,
		},
		// product purchase example
		{
			amount:30,
			label: "Product Purchase", 
			taxRate:6,
			shipping:10
		}
	],
	arrItem:[
		{
			name:'Product/Service',
			amount:2
		}
	],
	selectMessage: "Select Payment Option and Click Buy Now",
	buttonImage: "Buy now", // Must be "Buy now", "Checkout", "Donate" or "Custom"
	// buttonImageURL: "", // only used when buttonImage is "Custom"
	subscriptionPaymentLimit: 0, // 0 is unlimited, Otherwise you can set this between 2 and 52
	subscriptionRetry: true, // true will retry 2 times before cancelling subscription.
	subscriptionModifyEnabled: false, // true will allow the customer to change subscription - not recommended in most cases
	subscriptionTrialEnabled: false, // true will allow a different price or $0 price at the beginning of the subscription
	// subscriptionTrialPeriod: 'M', // M = month | Y = year | D = day | When subscriptionTrialEnabled is true, this value determine the length of the trial.
	// subscriptionTrialAmount: 0, // When subscriptionTrialEnabled is true, this value determine the price of the trial.  The price can be 0 or more.
	sandbox:false, // requires paypal developer sandbox account for "business" field if set to true
	business: "", // paypal merchant id (recommended) or paypal email address
	// invoice: 1, // must be unique on each transaction or don't specify one
	hideLabel: false,
	ipnURL: request.zos.currentHostName&"/z/misc/paypal/ipn", // It is better if this URL uses SSL
	returnURL: request.zos.currentHostName&"/z/misc/paypal/thank-you", // Note: The user is not sent to this URL automatically. They have to click a button after paying.
	returnLabel: "Continue shopping", // after payment, there is a button that will go to the return URL, this field changes the text on that button
	disableNote: true, // Set to false to allow the customer to enter notes in a comments field that is sent along with their payment.
	disableShipping: true, // Set to false to enable paypal's shipping features
	bottomMessage: "No PayPal account is required"
};
application.zcore.paypal.displayButton(ts);
 --->
<cffunction name="displayButton" localmode="modern" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	ts={
		buttonImage: "Buy now",
		// buttonImageURL: "",
		subscriptionPaymentLimit: 0,
		subscriptionRetry: true,
		subscriptionModifyEnabled: false,
		subscriptionTrialEnabled: false,
		// subscriptionTrialPeriod: 'M', 
		// subscriptionTrialAmount: 0,
		sandbox:false,
		business: "",
		hideLabel: false,
		ipnURL: request.zos.currentHostName&"/z/misc/paypal/ipn", 
		returnURL: request.zos.currentHostName&"/z/misc/paypal/thank-you",
		returnLabel: "Continue shopping", 
		selectMessage: "Select Payment Option and Click Buy Now",
		disableNote: true,
		disableShipping: true,
		bottomMessage: "No PayPal account is required"
	};
	ss=arguments.struct;
	structappend(ss, ts, false);
	if(not structkeyexists(ss, 'business')){
		throw("arguments.struct.business is required");
	}
	if(not structkeyexists(ss, 'arrAmount') or arraylen(ss.arrAmount) EQ 0){
		throw("arguments.struct.arrAmount is required");
	}
	if(not structkeyexists(ss, 'hideLabel')){
		ss.hideLabel=false;
	}
	if(ss.hideLabel and arraylen(ss.arrAmount) NEQ 1){
		throw("arguments.ss.arrAmount must have only 1 amount struct in the array when arguments.struct.hideLabel is true.");
	}
	if(structkeyexists(ss, 'buttonImage')){
		if(ss.buttonImage EQ "Buy now"){
			image='https://www.paypal.com/en_US/i/btn/btn_buynowCC_LG.gif';
		}else if(ss.buttonImage EQ "Checkout"){
			image='https://www.paypal.com/en_US/i/btn/btn_xpressCheckout.gif';
		}else if(ss.buttonImage EQ "Donate"){
			image='https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif';
		}else if(ss.buttonImage EQ "Custom"){
			if(not structkeyexists(ss, 'buttonImageURL')){
				throw("arguments.struct.buttonImageURL is required when arguments.buttonImage is Custom");
			}
			image=ss.buttonImageURL;
		}else{
			throw('arguments.struct.buttonImage must be "Buy now", "Checkout", "Donate" or "Custom"');
		}
	}else{
		image='https://www.paypal.com/en_US/i/btn/btn_buynowCC_LG.gif';
	}
	subscriptionEnabled=false;
	arrHidden=[];
	arrSelect=[];
	selectHidden='';
	for(i=1;i LTE arraylen(ss.arrAmount);i++){
		c=ss.arrAmount[i];
		if(structkeyexists(c, 'period')){
			if(c.period NEQ "M" and c.period NEQ "Y" and c.period NEQ "D"){
				throw("period must be M, Y, or D");
			}
			subscriptionEnabled=true; 
		}else{
			c.period='M';
		}
		if(not structkeyexists(c, 'frequency')){
			c.frequency=1;
		}
		if(not isnumeric(c.frequency)){
			throw("frequency must be an integer 0 or higher.");
		}
		if(not ss.hideLabel and not structkeyexists(c, 'label')){
			throw("Each arrAmount struct must have a label if arguments.struct.hideLabel is false.");
		}
		arrayAppend(arrHidden, '<input type="hidden" name="option_select#i-1#" value="#htmleditformat(c.label)#">
		<input type="hidden" name="option_amount#i-1#" value="#c.amount#">
		<input type="hidden" name="option_period#i-1#" value="#c.period#">
		<input type="hidden" name="option_frequency#i-1#" value="#c.frequency#">');
		if(ss.hideLabel){
			selectHidden='<input type="hidden" name="os0" value="#htmleditformat(c.label)#" />';
		}else{
			arrayAppend(arrSelect, '<option value="#htmleditformat(c.label)#">#htmleditformat(c.label)#</option>');
		}
	} 
	sandboxEnabled=false;
	if(request.zOS.thisIsTestServer or ss.sandbox){
		sandboxEnabled=true;	
	}
	paypalUrl="https://www.paypal.com/cgi-bin/webscr";
	if(sandboxEnabled){
		if(not structkeyexists(request.zos, 'paypalSandboxMerchantID') or request.zos.paypalSandboxMerchantID EQ ""){
			throw("request.zos.paypalSandboxMerchantID is required to be setup in config.cfc when sandbox is true");
		}
		ss.business=request.zos.paypalSandboxMerchantID;
		paypalUrl="https://www.sandbox.paypal.com/cgi-bin/webscr";
	}
	</cfscript> 
	<form name="paypalForm" action="#paypalUrl#" method="post" style="margin:0px; padding:0px;">
		<cfif subscriptionEnabled>
			<input type="hidden" name="cmd" id="paypal_cmd" value="_xclick-subscriptions" /><!--- subscriptions checkout --->
		<cfelse>
			<input type="hidden" name="cmd" id="paypal_cmd" value="_xclick" /><!--- regular checkout --->
		</cfif>
		<cfif sandboxEnabled>
			<input type="hidden" name="business" value="#htmleditformat(request.zos.paypalSandboxMerchantID)#" />
		
		<cfelse>
			<input type="hidden" name="business" value="#ss.business#" /><!--- merchant id --->
		</cfif>
		<input type="hidden" name="lc" value="US" /><!--- language --->
		<cfif structkeyexists(ss, 'invoice')>
	
			<input type="hidden" name="invoice" value="#htmleditformat(ss.invoice)#" /><!--- invoice_id number --->
		</cfif>

		<cfscript>
		if(arraylen(ss.arrItem) EQ 0){
			throw("arguments.struct.arrItem is required");
		}
		if(arraylen(ss.arrItem) EQ 1){
			echo('<input type="hidden" name="item_name" value="#htmleditformat(ss.arrItem[1].name)#" />');
			if(structkeyexists(ss.arrItem[1], 'number')){
				echo('<input type="hidden" name="item_number" value="#htmleditformat(ss.arrItem[1].number)#" />');
			}
		}else{
			for(i=1;i LTE arraylen(ss.arrItem);i++){
				echo('<input type="hidden" name="item_name_#i#" value="#htmleditformat(ss.arrItem[i].name)#" />
				<input type="hidden" name="amount_#i#" value="#htmleditformat(ss.arrItem[i].amount)#" />');
				if(structkeyexists(ss.arrItem[i], 'number')){
					echo('<input type="hidden" name="item_number" value="#htmleditformat(ss.arrItem[i].number)#" />');
				}
			}
		}
		</cfscript>

		<input type="hidden" name="modify" value="<cfif ss.subscriptionModifyEnabled>1<cfelse>0</cfif>" /><!--- prevent users from modifying subscriptions ---> 
		<cfif ss.disableNote>
			<input type="hidden" name="no_note" value="1" /><!--- disable notes --->
		</cfif>
		<cfif ss.disableShipping>
			<input type="hidden" name="no_shipping" value="1" /><!--- disable shipping --->
		</cfif>
		
		<cfscript>
		if(ss.subscriptionTrialEnabled){
			if(not structkeyexists(ss, 'subscriptionTrialPeriod')){
				throw("arguments.struct.subscriptionTrialPeriod is required when arguments.struct.subscriptionTrialEnabled is true");
			}
			if(not structkeyexists(ss, 'subscriptionTrialAmount')){
				throw("arguments.struct.subscriptionTrialAmount is required when arguments.struct.subscriptionTrialEnabled is true");
			}
			if(not structkeyexists(ss, 'subscriptionTrialLength')){
				throw("arguments.struct.subscriptionTrialLength is required when arguments.struct.subscriptionTrialEnabled is true");
			}
			echo('<input type="hidden" name="a1" value="#ss.subscriptionTrialAmount#" />
			<input type="hidden" name="p1" value="#ss.subscriptionTrialLength#" />
			<input type="hidden" name="t1" value="#ss.subscriptionTrialPeriod#" />');
		}
		if(structkeyexists(ss, 'subscriptionPaymentLimit') and ss.subscriptionPaymentLimit NEQ 0){
			if(ss.subscriptionPaymentLimit GTE 2 and ss.subscriptionPaymentLimit LTE 52){
				echo('<input type="hidden" name="srt" id="paypal_srt" value="#ss.subscriptionPaymentLimit#" />');
			}else{
				throw("arguments.struct.subscriptionPaymentLimit must be between 2 and 52");
			}
		}
		</cfscript>
		<input type="hidden" name="src" id="paypal_src" value="1" /><!--- 1 for recurring, 0 for not recurring --->
		<cfif ss.subscriptionPaymentLimit NEQ 0>
		<input type="hidden" name="srt" id="paypal_srt" value="#ss.subscriptionPaymentLimit#" /><!--- limit recurring billing cycles --->
		</cfif>
		<cfif ss.subscriptionRetry>
			<input type="hidden" name="sra" value="1" /><!--- reattempt failed subscription payment --->
		</cfif>
		<input type="hidden" name="currency_code" value="USD" />
		<input type="hidden" name="bn" value="PP-SubscriptionsBF:btn_buynowCC_LG.gif:NonHosted" />
		<input type="hidden" name="notify_url" value="#htmleditformat(ss.ipnURL)#" />
		<input type="hidden" name="return" id="paypal_return_url" value="#htmleditformat(ss.returnURL)#" />
		<input type="hidden" name="rm" value="2" />
		<input type="hidden" name="cbt" value="#htmleditformat(ss.returnLabel)#" />	 
		
		<input type="hidden" name="option_index" value="0" /> 
		
		<div class="zPaypalButton">
			<cfif selectHidden NEQ "">
				#selectHidden#
			<cfelse>
				<div class="zPaypalSelectMessage"><input type="hidden" name="on0" value="Payment Option">#ss.selectMessage#</div>
				<div class="zPaypalSelect">
					<select name="os0" id="paypal_optionselect" onChange="updatePaypalForm(this);" size="1">
						#arrayToList(arrSelect, chr(10))#
					</select>
				</div>
			</cfif>
			<div class="zPaypalImageDiv">
				<input type="image" src="#image#" name="submit" alt="PayPal - The safer, easier way to pay online!" />
		   	</div>
		   	<cfif ss.bottomMessage NEQ "">
				<div class="zPaypalBottomMessage">#ss.bottomMessage#</div>
			</cfif>
		</div>
	</form>
</cffunction>

<cffunction name="setDebugData" localmode="modern" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	arguments.struct.option_selection1="One time payment";
	arguments.struct.ipn_track_id="576f2e315ffd1";
	arguments.struct.charset="windows-1252";
	arguments.struct.receiver_id="DPCMATR4C2RE4";
	arguments.struct.protection_eligibility="Ineligible";
	arguments.struct.resend="true";
	arguments.struct.payment_type="instant";
	arguments.struct.payment_status="Completed";
	arguments.struct.shipping="0.00";
	arguments.struct.payer_status="verified";
	arguments.struct.tax="0.00";
	arguments.struct.payment_gross="150.00";
	arguments.struct.handling_amount="0.00";
	arguments.struct.receiver_email="receiver@yourcompany.com";
	arguments.struct.first_name="First";
	arguments.struct.last_name="Last";
	arguments.struct.item_number="";
	arguments.struct.verify_sign="Ai1PaghZh5FmBLCDCTQpwG8jB264AdJXSW248UAUciEPzCLnAhBdy4G.";
	arguments.struct.quantity="1";
	arguments.struct.residence_country="US";
	arguments.struct.custom="";
	arguments.struct.payment_date="09:01:26 Jul 21, 2014 PDT";
	arguments.struct.payer_email="client@email.com";
	arguments.struct.payer_id="RY9Q8EYMZXGSQ";
	arguments.struct.payment_fee="4.65";
	arguments.struct.notify_version="3.8";
	arguments.struct.txn_type="web_accept";
	arguments.struct.mc_currency="USD";
	arguments.struct.payer_business_name="Client";
	arguments.struct.txn_id="0WF11855YK1274414";
	arguments.struct.option_name1="Payment Option";
	arguments.struct.invoice="1146";
	arguments.struct.mc_fee="4.65";
	arguments.struct.mc_gross="150.00";
	arguments.struct.item_name="Invoice ##1";
	arguments.struct.transaction_subject="";
	arguments.struct.business=request.zos.paypalSandboxMerchantID;
	</cfscript>
</cffunction>

<cffunction name="verifyIPN" localmode="modern" access="public" returntype="struct">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="sandboxEnabled" type="boolean" required="yes">
	<cfscript>
	ss=arguments.struct;
	postURL="https://www.paypal.com/cgi-bin/webscr";
	if(arguments.sandboxEnabled){
		postURL="https://www.sandbox.paypal.com/cgi-bin/webscr";
	}
	http url="#postURL#" charset="#ss.charset#" port="443" method="POST" throwonerror="no" timeout="30"{
		httpparam type="formfield" name="cmd" encoded="yes" value="_notify-validate";
		for(i in ss){
			httpparam type="formfield" name="#lcase(i)#" encoded="yes" value="#ss[i]#";
		}
	}
	if(left(CFHTTP.statusCode,3) NEQ '200'){
		// failed.
		return { errorMessage:"Failed to verify IPN due to HTTP failure: ", success:false};
	}else{
		if(trim(cfhttp.FileContent) EQ "VERIFIED"){
			return { errorMessage:"", success:true};
		}else{
			return { errorMessage:"Failed to verify IPN with result being: #cfhttp.FileContent#", success:true};
		}
	} 
	</cfscript>
</cffunction>
	
	
<cffunction name="processIPN" localmode="modern" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	ss=arguments.struct; 
	setting requesttimeout="60";

	if(structkeyexists(ss, 'debug1')){
		/**/
		echo('debug disabled32432');
		abort;
	}
	sandboxEnabled=false;
	if(application.zcore.functions.zso(ss, 'test_ipn',false,0) EQ 1){
		// force test if paypal post is a test.
		sandboxEnabled=true;	
	}

	// force off test mode so I can test database updates.
	//sandboxEnabled=false;

	structdelete(ss,"fieldnames");
	ss.charset=application.zcore.functions.zso(ss, 'charset', false, 'utf-8');

	ss.invoice=application.zcore.functions.zso(ss, 'invoice');
	if(ss.invoice CONTAINS ","){
		ss.invoice=listgetat(ss.invoice,1,",");	
	}else if(ss.invoice CONTAINS "-"){
		ss.invoice=listgetat(ss.invoice,1,"-");	
	}
	ts=structnew();
	ts.datasource="intranet";
	ts.table="paypal_ipn_log";
	ts.struct=structnew();
	ts.struct.invoice_id=ss.invoice;
	if(failedIpn){
		ts.struct.paypal_ipn_log_verified=0;
	}else{
		ts.struct.paypal_ipn_log_verified=1;
	}
	ts.struct.paypal_ipn_log_datetime=dateformat(now(),"yyyy-mm-dd")&" "&timeformat(now(),"HH:mm:ss");
	ts.struct.paypal_ipn_log_updated_datetime=ts.struct.paypal_ipn_log_datetime;
	ts.struct.paypal_ipn_log_data=serializeJson(ss);
	paypal_ipn_log_id=application.zcore.functions.zInsert(ts);
	
	if(failedIpn EQ false){
		echo('Not failed1<br />');
		// mark invoice paid if the values match up with the complete transaction etc.
		skipProcessing=false;
		if(structkeyexists(ss, 'txn_type')){
			if(ss.txn_type EQ "subscr_signup"){
				qInvoice=zexecutesql("UPDATE invoice SET invoice_paypal_subscription_active='1' WHERE invoice_id = '"&application.zcore.functions.zescape(ss.invoice)&"'","intranet");
				skipProcessing=true;
			}else if(ss.txn_type EQ "subscr_eot"){
				qInvoice=zexecutesql("UPDATE invoice SET invoice_paypal_subscription_active='0' WHERE invoice_id = '"&application.zcore.functions.zescape(ss.invoice)&"'","intranet");
				skipProcessing=true;
			}else if(ss.txn_type EQ "subscr_cancel"){
				qInvoice=zexecutesql("UPDATE invoice SET invoice_paypal_subscription_active='0', invoice_status='1' WHERE invoice_id = '"&application.zcore.functions.zescape(ss.invoice)&"'","intranet");
				skipProcessing=true;
			}else if(ss.txn_type EQ "subscr_failed"){
				qInvoice=zexecutesql("UPDATE invoice SET invoice_paypal_subscription_active='0' WHERE invoice_id = '"&application.zcore.functions.zescape(ss.invoice)&"'","intranet");
				skipProcessing=true;
			}else if(ss.txn_type EQ "subscr_modify"){
				qInvoice=zexecutesql("select * FROM invoice WHERE invoice_id = '"&application.zcore.functions.zescape(ss.invoice)&"'","intranet");
				statusMessage="Successfully verified IPN, but the txn_type was #ss.txn_type# and the following changes were made: ";
				if(qInvoice.recordcount NEQ 0){
					newAmount=0;
					if(application.zcore.functions.zso(ss, 'amount1',true) NEQ 0){
						newAmount=amount1;
					}else if(application.zcore.functions.zso(ss, 'amount2',true) NEQ 0){
						newAmount=amount2;
					}else if(application.zcore.functions.zso(ss, 'amount3',true) NEQ 0){
						newAmount=amount3;
					}
					if(newAmount NEQ 0){
						statusMessage&=" | Amount was updated";
						zexecutesql("UPDATE invoice SET invoice_cost='"&application.zcore.functions.zescape(newAmount)&"' WHERE invoice_id = '"&application.zcore.functions.zescape(ss.invoice)&"'","intranet");
					}
					if(application.zcore.functions.zso(ss, 'recur_times',true) NEQ 0){
						recurCount=application.zcore.functions.zso(ss, 'recur_times')-1;
						statusMessage&=" | Billing Cycles was updated";
						newCount=qInvoice.invoice_recurring_paid_cycles+recurCount;
						if(option_selection1 EQ "Annual payment (auto-pay)"){
							newCount=qInvoice.invoice_recurring_paid_cycles+(recurCount*12);
						}
						zexecutesql("UPDATE invoice SET invoice_recurring_billing_cycles='"&application.zcore.functions.zescape(newCount)&"' WHERE invoice_id = '"&application.zcore.functions.zescape(ss.invoice)&"'","intranet");
					}
				}
				//failedIpn=true;
				skipProcessing=true;
			}else if((ss.txn_type NEQ "subscr_payment" and ss.txn_type NEQ "web_accept") or application.zcore.functions.zso(ss, 'mc_gross',true) LT 0){
				// 
				statusMessage="Successfully verified IPN, but the txn_type was #ss.txn_type# and mc_gross was "&application.zcore.functions.zso(ss, 'mc_gross')&" which are not processed by my system. ";
				failedIpn=true;
			}
		}else{
			statusMessage="Payment status: "&application.zcore.functions.zso(ss, 'payment_status')&".";
			skipProcessing=true;
		}
		if(failedIpn EQ false and skipProcessing EQ false){
			echo('Not failed2<br />');
			// only completed positive payments that are type: subscr_payment or web_accept are processed.
			if(payment_status EQ "Completed"){// or payment_status EQ "Pending"){
				if(ss.invoice EQ ""){
					failedIpn=true;
					statusMessage="Invoice id was missing - You must manually mark this payment paid.";
				}
				/*
				txn_type "subscr_signup" This Instant Payment Notification is for a subscription sign-up. 
				"subscr_cancel" This Instant Payment Notification is for a subscription cancellation. 
				"subscr_modify" This Instant Payment Notification is for a subscription modification. 
				"subscr_failed" This Instant Payment Notification is for a subscription payment failure. 
				"subscr_payment" This Instant Payment Notification is for a subscription payment. 
				"subscr_eot" This Instant Payment Notification is for a subscription's end of term. 
				*/
				// this invoice was paid!
				// find invoice
				qInvoice=zexecutesql("select * FROM invoice WHERE invoice_id = '"&application.zcore.functions.zescape(ss.invoice)&"'","intranet");
				if(qInvoice.recordcount EQ 0){
					statusMessage="Successfully verified IPN, but no invoice could be found. Must be spam or a bug.";
					failedIpn=true;
				}
				if(qInvoice.invoice_status EQ 2){
					statusMessage="Successfully verified IPN and found invoice, but invoice was cancelled.  Need to manually handle the transaction.";
					failedIpn=true;
				}
				if(qInvoice.invoice_status EQ 1){
					statusMessage="Successfully verified IPN and found invoice, but invoice was already paid in full. Check for recurring or possible double billing.";
					failedIpn=true;
				}
				if(qInvoice.recordcount NEQ 0 and failedIpn EQ false){
					echo('Not failed3<br />');
					cycleCount=0;
					if(option_selection1 EQ "Annual payment (auto-pay)"){
						cycleCount=12;
						recurringPaidCycles=qInvoice.invoice_recurring_paid_cycles+12;
						if(qInvoice.invoice_cost*12 NEQ mc_gross){
							statusMessage="Successfully verified IPN and found invoice, but invoice cost doesn't match gross paypal amount paid.";
							failedIpn=true;
						}
					}else if(option_selection1 EQ "Pay remaining balance"){
						if(qInvoice.invoice_recurring_billing_cycles EQ 0){
							cycleCount=1;
							recurringPaidCycles=qInvoice.invoice_recurring_paid_cycles+1;
						}else{
							cycleCount=qInvoice.invoice_recurring_billing_cycles;
							recurringPaidCycles=qInvoice.invoice_recurring_billing_cycles;
						}
					}else{
						cycleCount=1;
						// monthly auto-pay or one time payments just increase the paid cycles
						if(qInvoice.invoice_recurring EQ 1){
							c393=round(mc_gross/qInvoice.invoice_cost);
							recurringPaidCycles=qInvoice.invoice_recurring_paid_cycles+c393;
						}else{
							recurringPaidCycles=qInvoice.invoice_recurring_paid_cycles+1;
						}
						if(qInvoice.invoice_cost NEQ mc_gross){
							statusMessage="Successfully verified IPN and found invoice, but invoice cost doesn't match gross paypal amount paid.";
							failedIpn=true;
						}
					}
					if(qInvoice.invoice_recurring EQ 1){
						newInvoiceStatus=0;
						if(qInvoice.invoice_recurring_billing_cycles NEQ 0){
							if(recurringPaidCycles GT qInvoice.invoice_recurring_billing_cycles){
								statusMessage="Successfully verified IPN and found invoice, but too many billing cycles have been paid for.  This payment was recorded, but need to check why the subscription didn't stop and maybe refund this transaction.";
								failedIpn=true;
								newInvoiceStatus=1;
								// all payments have been made for this recurring invoice, mark as fully paid
							}else if(recurringPaidCycles EQ qInvoice.invoice_recurring_billing_cycles){
								// all payments have been made for this recurring invoice, mark as fully paid
								newInvoiceStatus=1;
							}
						}
						// create invoice_payment for recurring invoices.
						ts=structnew();
						ts.datasource="intranet";
						ts.table="invoice_payment";
						ts.struct=structnew();
						ts.struct.invoice_id=qInvoice.invoice_id;
						ts.struct.invoice_payment_cancelled=0;
						ts.struct.invoice_payment_paypal_merchant_fee=application.zcore.functions.zso(ss, 'mc_fee',0);
						if(payment_status EQ "Pending"){
							ts.struct.invoice_payment_paypal_pending=1;
						}else{
							ts.struct.invoice_payment_paypal_pending=0;
						}
						ts.struct.invoice_payment_amount=ss.mc_gross;
						ts.struct.invoice_payment_paid_cycles=cycleCount;
						ts.struct.invoice_payment_datetime=dateformat(now(),"yyyy-mm-dd")&" "&timeformat(now(),"HH:mm:ss");
						ts.struct.invoice_payment_paypal_email=ss.payer_email; 
						ts.struct.invoice_payment_paypal_ipn_data=arraytolist(arrForm,chr(10));
						if(sandboxEnabled EQ false){
							invoice_payment_id=application.zcore.functions.zInsert(ts);
							if(invoice_payment_id EQ false){
								statusMessage="Successfully verified IPN and found invoice, but invoice_payment record failed to be inserted to database.";
								failedIpn=true;
							}
						}
						invoicePaymentStruct=ts;
					}else{
						newInvoiceStatus=1;
					}
					
					echo('Not failed4<br />');
					ts=structnew();
					ts.datasource="intranet";
					ts.table="invoice";
					ts.struct=structnew();
					if(structkeyexists(ss, 'debug1')){
						ts.debug=true;
					}
					ts.forceWhereFields="invoice_id";
					ts.struct.invoice_id=qInvoice.invoice_id;
					ts.struct.invoice_status=newInvoiceStatus;
					ts.struct.invoice_recurring_paid_cycles=recurringPaidCycles;
					ts.struct.invoice_paypal_merchant_fee=application.zcore.functions.zso(ss, 'mc_fee', false, 0);
					ts.struct.invoice_paid=ss.mc_gross;
					ts.struct.invoice_paid_datetime=dateformat(now(),"yyyy-mm-dd")&" "&timeformat(now(),"HH:mm:ss");
					if(option_selection1 NEQ "Pay Remaining Balance" and option_selection1 NEQ "Annual payment (auto-pay)" and qInvoice.invoice_cost-ss.mc_gross LT 0){
						statusMessage="Successfully verified IPN and found and processed invoice, but customer overpaid on paypal by "&(ss.mc_gross-qInvoice.invoice_cost);
						failedIpn=true;
					}
					ts.struct.invoice_paypal_email=ss.payer_email; 
					ts.struct.invoice_paypal_ipn_data=arraytolist(arrForm,chr(10));
					r="test";
					if(sandboxEnabled EQ false){
						r=application.zcore.functions.zUpdate(ts);
						if(r EQ false){
							statusMessage="Successfully verified IPN and found invoice, but invoice database update failed.";
							failedIpn=true;
						}
					}
					invoiceStruct=ts;
					if(structkeyexists(ss, 'debug1')){
						writedump(r);
						writedump(request.zos.arrQueryLog);
						writedump(invoiceStruct);
					}
				}
			}else{
				statusMessage="Successfully verified IPN, but payment_status was #ss.payment_status#.";
				failedIpn=true;
			}
		}
	}
	if(structkeyexists(ss, 'debug1')){
		verifyResult={success:true, errorMessage:""};
	}else{
		verifyResult=verifyIPN();
		if(not verifyResult.success){
			throw(verifyResult.errorMessage);
		}
	}
	if(sandboxEnabled or failedIpn){
		echo('Failed<br />');
		savecontent variable="allVars"{
			echo('#statusMessage#<br><br>');
			if(isDefined('invoicePaymentStruct')){
				echo('<h2>INVOICE PAYMENT STRUCT</h2>');
				writedump(invoicePaymentStruct);
				echo('<br>');
			}
			if(isDefined('invoiceStruct')){
				echo('<h2>INVOICE STRUCT</h2>');
				writedump(invoiceStruct);
				echo('<br>');
			}
			writedump(ss);
			echo('<br>');
			writedump(cfhttp);
			echo('<br>');
			writedump(request.zos.cgi);
		}
		if(failedIpn){
			mail spoolenable="no"  to="#request.zos.developerEmailTo#" from="#request.zos.developerEmailFrom#" subject="Paypal IPN Failue on #request.zos.currentHostName#" type="html" charset="windows-1252"{
				echo('<html>
					<head><title>Error</title></head><body>
			There was a failed IPN<br>
			 <a href="#request.zos.currentHostName#/z/ecommerce/admin/paypal/ipnView?paypal_ipn_log_id=#paypal_ipn_log_id#">View failed IPN</a><br><br>
			 All Request/Response Data:<br><br>
			 #allVars#
			 
			</body></html>');
			}
		}
	}
	abort;
	</cfscript> 
</cffunction>
</cfoutput>
</cfcomponent>