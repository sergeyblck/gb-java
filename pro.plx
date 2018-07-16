use strict;

use POSIX;

use lib q(/var/www/data/ucoin.net/lib);
use base qw(common);

use utf8;
use open qw/:std :utf8/;


sub main () {

	my $common = common->new();

	my $xml = '';
	my $uid = $common->usr->id;

#	if ($uid == 1) {
#		$common->{'dbh'}->disconnect();
#		print $common->{'cgi'}->redirect(
#				-location => "/donate",
#				-status => 301
#		);
#		exit;
#	}

	if ($uid == 50917) {
		$common->{'dbh'}->disconnect();
		print $common->{'cgi'}->redirect(
				-location => "/",
		);
		exit;
	}

	
	if ($common->{'cgi'}->param('uid')) {
		if ($common->{'cgi'}->param('uid') > 1) {
			$uid = $common->dbh->selectrow_array(qq{
				select id from users where id = ? and id > 1
			}, undef, $common->{'cgi'}->param('uid') ) || $uid;
		} else {
			$uid = $common->dbh->selectrow_array(qq{
				select id from users where lower(publicname) = lower(?) and id > 1
			}, undef, $common->{'cgi'}->param('uid') ) || $uid;
		}
	}

	my $country = $common->{'dbh'}->selectrow_array("select alpha2 from country_main where id = (select country_main_id from users where id = ?)", undef, $uid);

	if ($common->{'cgi'}->param('trial')) {

		$common->{'dbh'}->do(qq{
			insert into users_payment (users_id, is_free, period)
			select id, 1, 1
			from users
			where id = ? and pro_trial is null
		}, undef, $common->usr->id);
		$common->{'dbh'}->do(qq{update users set pro = 1, pro_trial = 1, pro_last_date = now() + interval '1 month' where id = ? and pro_trial is null}, undef, $common->usr->id);
		$common->{'dbh'}->commit();

		#my $subject = "PRO Trial - " . $common->usr->name . " [$country] - " . $common->usr->id;
		#$common->SendInfoEmail('info@ucoin.net', $subject, $subject);

		$common->{'dbh'}->disconnect();
		print $common->{'cgi'}->redirect("/pro");
		exit;
	}

	if ($common->{'cgi'}->param('discount')) {
		
		$common->{'dbh'}->do(qq{update users_rate set last_date = public_date + interval '5 days', status = 0 where users_id = ?}, undef, $uid);
		$common->{'dbh'}->commit();

		#my $subject = "PRO Discount - " . $common->usr->name . " [$country] - " . $common->usr->id;
		#$common->SendInfoEmail('info@ucoin.net', $subject, $subject);

		$common->{'dbh'}->disconnect();
		print $common->{'cgi'}->redirect("/pro/?uid=$uid");
		exit;
	}

	my $mask = ($common->{'lang_code'} =~ /ru|uk|be|it/) ? 'dd.mm.yy' : 'mm/dd/yy'; #'Mon DD, YYYY';
	my ($user_id, $user_name, $avatar, $pro, $pro_date, $pro_day) = $common->{'dbh'}->selectrow_array(qq{
		select id, publicname, avatar_location, pro, case when ( date_part('year',pro_last_date) = date_part('year', now())) then to_char (pro_last_date, 'Mon dd')
			else to_char (pro_last_date, '$mask') end, pro_last_date - current_date
		from users u where id = ?
	}, undef, $uid);

	if ($pro_day == 1) {$pro_day = '1 day';}
	elsif ($pro_day == 0) {$pro_day = 'last day';}
	else {$pro_day = qq{$pro_day days};}

	$xml .= qq{
		<user id="$user_id" pro="$pro" avatar-loc="$avatar" >
			<pro day="$pro_day">$pro_date</pro>
			<publicname>$user_name</publicname>
		</user>
	};

	my ($discount, $disc_per, $disc_date, $disc_days, $disc_age, $disc_coins) = $common->{'dbh'}->selectrow_array(q{
		select discount, trunc(discount*100) as perc, to_char(last_date, 'Mon dd') as last_date,
			   date_trunc('day', last_date - now()) as time, age, coins
		from users_rate where users_id = ? and discount < 1
	}, undef, $uid);

	if ($discount && $disc_date) {
		$discount = 1 - $discount;
		if ($disc_days eq '00:00:00') {$disc_days = 'last day';}
		
		$xml .= qq{
			<discount value="$discount" percent="$disc_per" age="$disc_age" coins="$disc_coins">
				<date day="$disc_days">$disc_date</date>
			</discount>
		};
	} elsif ($discount && !$disc_date) {
		$xml .= qq{
			<rate percent="$disc_per" age="$disc_age" coins="$disc_coins" />
		};
	}

	my $myCy = $common->{'dbh'}->selectrow_array("select code from currency_main where id = ?", undef, $common->{'currency_id'});

	#my $myCountry = $common->{'dbh'}->selectrow_array("select alpha2 from country_main where id = (select country_main_id from users where id = ?)", undef, $common->usr->id);

	$common->{'currency_id'} = 5 unless ($myCy =~ /USD|EUR|RUB|AUD|GBP|HKD|DKK|CAD|MXN|TWD|NOK|PLN|SEK|CHF/);
	my $cy = ($common->{'cgi'}->param('cy')) ? $common->{'cgi'}->param('cy') : $common->{'currency_id'};



	$xml .= qq{<cy cur="$cy">};

	if ( $myCy =~ /RUB|UAH|BYN|KZT/ || $country =~ /RU|UA|KZ|BY|AM|AZ|EE|GE|KG|LV|LT|MD|TJ|TM|UZ/ ) {

		my ($id, $code, $left, $right) = $common->{'dbh'}->selectrow_array(qq{
			 select id, code, symbol_left, symbol_right
			 from currency_main
			 where code = 'RUB'
		}, undef);
		$xml .= qq{<item id="$id" left="$left" right="$right">$code</item>};
	}

	if ( $myCy =~ /AUD|GBP|HKD|DKK|CAD|MXN|TWD|NOK|PLN|SEK|CHF|CZK/ ) {
		my ($id, $code, $left, $right) = $common->{'dbh'}->selectrow_array(qq{
			 select id, code, symbol_left, symbol_right
			 from currency_main
			 where code = ?
		}, undef, $myCy);
		$xml .= qq{<item id="$id" left="$left" right="$right">$code</item>};
	}

	$xml .= qq{<item id="1" left="€ " right="">EUR</item><item id="5" left="US \$ " right="">USD</item>};

	$xml .= "</cy>";


	my @price;
	$price[1] = $common->proPrice($uid, 1, $cy, 1);
	$price[6] = $common->proPrice($uid, 6, $cy, 1);
	$price[12] = $common->proPrice($uid, 12, $cy, 1);
		
	$xml .= qq{<price one="$price[1]" six="$price[6]" twelve="$price[12]" />};
	if ($discount && $disc_date) {
		$price[1] = ceil($price[1]*$discount);
		$price[6] = ceil($price[6]*$discount);
		$price[12] = ceil($price[12]*$discount);
		$xml .= qq{<disc-price one="$price[1]" six="$price[6]" twelve="$price[12]" />}
	}	

#	if ( $cy == 31 || $cy == 73 || $cy == 49) {
#		my $k = $common->{'dbh'}->selectrow_array(qq{
#			select 
#				(select euro_value from currency_main where code='RUB')  / (select euro_value from currency_main where id=?)
#		}, undef, $cy);	
#		$price[1] = ceil($price[1]*$k);
#		$price[6] = ceil($price[6]*$k);
#		$price[12] = ceil($price[12]*$k);
#	}

	$xml .= qq{<total-price one="$price[1]" six="$price[6]" twelve="$price[12]" />};


	my $trial = $common->{'dbh'}->selectrow_array("select pro_trial from users where id = ?", undef, $common->usr->id);
	$xml .= qq{<trial use="$trial"></trial>};

	my $pp = $common->{'dbh'}->selectrow_array(q{
		select (select code from lang where id = u.lang_id)||'_'||(select alpha2 from country_main where id = u.country_main_id)
		from users u
		where id = ?
	}, undef, $common->usr->id) || 'en_US';

	$xml .= qq{<paypal lc="$pp" />};


#	if ( $myCy =~ /RUB/ && $common->usr->id == 2 ) {
#		
#		#use Digest::SHA3;
#		#use MIME::Base64 qw/encode_base64 decode_base64/;
#		#use JSON;
#
#		# Балюк Олександра можете спросить любого оператора, уточните при обращении, что передавали Ваш вопрос по неверной подписи на рассмотрение разработчикам.
#		my $public_key = 'i18293154355';
#		my $private_key = 'P1KY9NEqFJ4i7tUusqO68IkaBJn8I9EeDFISIrz4';
#		
#		my $json = q~{\"version\" : 3, \"public_key\" : \"~ . $public_key . q~\", \"action\" : \"pay\", \"amount\" : 1, \"currency\" : \"USD\", \"description\" : \"test\", \"order_id\" : \"1\"}~;
#
#		my $data = qx{echo -n "$json" | base64};
#		chomp $data;
#
#		my $signature=qx{echo -n "$private_key$data$private_key" | openssl dgst -binary -sha1 | base64};
#
#		$xml .= qq{
#			<liqpay>
#				<data>$data</data>
#				<signature>$signature</signature>
#				<json>$json</json>
#			</liqpay>
#		};
#	}

	$xml .= qq{
		<meta>
			<title>PRO is a Premium Account - uCoin.net</title>
		</meta>
	};

	my $settingsXML = $common->settingsXML();
	my $_cgi_paramXML=$common->cgiParamXML();
	$xml = qq{<?xml version="1.0" encoding="utf8"?>
				<document>
					<properties>
						<script>pro</script>
						<menu></menu>
						$_cgi_paramXML
					</properties>
					$settingsXML
					<content>
						$xml
					</content>
				</document>
		};
	$common->OutputTemplate("pro.xsl", join( "\n", $xml ) ); 
}
#------------------------------------------------------------------------------------------------------------

&main();
