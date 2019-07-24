#!/usr/bin/env perl

#author : Xiangjian Gou 
#email  : xjgou@stu.sicau.edu.cn
#date   : 2019/07/23

#Compile : perlapp --icon log.ico -g -f DecodeSudokuOnGui.pl -e=DecodeSudoku.exe

#load modules
use strict;
use warnings;
use Tk;
use Time::HiRes;

#declare package name
package Sudoku;

#set max run time
my $MaxTime = 10;

#build GUI
my ($FinalShow, $TimeEntry, %entry) = BuildGui();

Tk::MainLoop;

#some method

sub BuildGui {
    my $MainWin = MainWindow->new;

    $MainWin->geometry("620x500");

    $MainWin->title("DeSudoku");

    my $tool = $MainWin->Frame()->pack(-side => 'top', -fill => 'x');
    $tool->Label(-text => " DeSudoku : A fast tool for decode standard 9x9 Sudoku ")->pack();

    my $null1 = $MainWin->Frame()->pack(-side => 'top', -fill => 'x');
    $null1->Label(-text => '')->pack();

    my $author = $MainWin->Frame()->pack(-side => 'top', -fill => 'x');
    $author->Label(-text => " Author : Xiangjian Gou ")->pack();

    my $email = $MainWin->Frame()->pack(-side => 'top', -fill => 'x');
    $email->Label(-text => " E-mail : xjgou\@stu.sicau.edu.cn ")->pack();

    my $date = $MainWin->Frame()->pack(-side => 'top', -fill => 'x');
    $date->Label(-text => " Date : 2019-07-23 ")->pack();

    my $null2 = $MainWin->Frame()->pack(-side => 'top', -fill => 'x');
    $null2->Label(-text => '')->pack();

    my $note = $MainWin->Frame()->pack(-side => 'top', -fill => 'x');
    $note->Label(-text => "notice : If there is no number in a location, you can leave it blank !")->pack();

    my $null3 = $MainWin->Frame()->pack(-side => 'top', -fill => 'x');
    $null3->Label(-text => '')->pack();

    my $SetTime = $MainWin->Frame()->pack(-side => 'top', -fill => 'x');
    $SetTime->Label(-text => '')->pack(-ipadx => 100, -side => "left");
    $SetTime->Label(-text => "The maximum time of calculation : ")->pack(-side => "left");
    my $TimeEntry = $SetTime->Entry(-background => "white", -width => 5, -foreground => "black")->pack(-side => "left");
    $TimeEntry->insert('end', '10');
    $SetTime->Label(-text => 's')->pack(-side => "left");

    my $null4 = $MainWin->Frame()->pack(-side => 'top', -fill => 'x');
    $null4->Label(-text => '')->pack();

    my %entry;
    foreach my $i (1 .. 9) {
        if ($i == 4 or $i == 7) {
            my $MainFrame = $MainWin->Frame()->pack(-side => 'top', -fill => 'x');
            $MainFrame->Label(-text => '')->pack();
        }
        my $MainFrame = $MainWin->Frame()->pack(-side => 'top', -fill => 'x');
        $MainFrame->Label(-text => '')->pack(-ipadx => 70, -side => "left");
        foreach my $j (1 .. 9) {
            $entry{$i}{$j} = $MainFrame->Entry(-background => "white", -width => 4, -foreground => "black")->pack(-side => "left");
            $MainFrame->Label(-text => '')->pack(-ipadx => 10, -side => "left") if $j == 3 or $j == 6;
        }
    }

    my $null5 = $MainWin->Frame()->pack(-side => 'top', -fill => 'x');
    $null5->Label(-text => '')->pack();

    my $MainFrame2 = $MainWin->Frame()->pack(-side => 'top', -fill => 'x');
    $MainFrame2->Label(-text => '')->pack(-ipadx => 30, -side => "left");
    $MainFrame2->Button(-text => "Clear", -command => \&Clear)->pack(-ipadx => 30, -side => "left");
    $MainFrame2->Label(-text => '')->pack(-ipadx => 20, -side => "left");
    $MainFrame2->Button(-text => "Start to Decode", -command => \&DeSudoku)->pack(-ipadx => 60, -side => "left");
    $MainFrame2->Label(-text => '')->pack(-ipadx => 20, -side => "left");
    $MainFrame2->Button(-text => "Close", -command => sub{exit})->pack(-ipadx => 30, -side => "left");

    my $null6 = $MainWin->Frame()->pack(-side => 'top', -fill => 'x');
    $null6->Label(-text => '')->pack();

    my $MainFrame = $MainWin->Frame()->pack(-side => 'top', -fill => 'x');
    my $FinalShow = $MainFrame->Entry(-background => 'black', -foreground => 'white')->pack(-ipadx => 80);
    $FinalShow->insert('end', '                     Here will show run information !');

    return $FinalShow, $TimeEntry, %entry;
}

sub DeSudoku {
    my $StartTime = join '.', Time::HiRes::gettimeofday;
    my %input;
    foreach my $i (1 .. 9) {
        foreach my $j (1 .. 9) {
            my $text = $entry{$i}{$j}->get;
            $input{$i}{$j} = $text || '';
        }
    }
    $MaxTime = 10;
    $MaxTime = $TimeEntry->get || $MaxTime;
    my $query = Sudoku->new(\%input);
    my $judge = 0;
    my $StartTimeJudge = join '.', Time::HiRes::gettimeofday;
    while (1) {
        $query->exclude;
        my $StartCount = $query->FinishCount;
        $query->remainder;
        my $EndCount = $query->FinishCount;
        if ($EndCount == @$query**2) {
            $judge = 1;
            last;
        }
        else {
            if ($EndCount == $StartCount) {
                $judge = $query->guess;
                last if ! $judge;
            }
        }
        my $EndTimeJudge = join '.', Time::HiRes::gettimeofday;
        if ($EndTimeJudge - $StartTimeJudge > $MaxTime) {
            $judge = 0;
            last;
        }
    }
    if (! $judge) {
        $FinalShow->delete('0.0', 'end');
        $FinalShow->insert('end', "   Sorry, I can't decode this Sudoku within $MaxTime seconds ! ");
        return;
    }
    my $OrRight = $query->OrRight;
    if (! $OrRight) {
        $FinalShow->delete('0.0', 'end');
        $FinalShow->insert('end', "   The digits of provided may be error, please check again ! ");
        return;
    }
    my $EndTime = join '.', Time::HiRes::gettimeofday;
    my $RunTime = sprintf "%.3f s", $EndTime-$StartTime;
    foreach my $i (0 .. $#$query) {
        foreach my $j (0 .. $#{$query->[$i]}) {
            $entry{$i+1}{$j+1}->delete('0.0', 'end');
            $entry{$i+1}{$j+1}->insert('end', $query->[$i][$j]);
        }
    }
    $FinalShow->delete('0.0', 'end');
    $FinalShow->insert('end', "                               Run Time = $RunTime ");
}

sub Clear {
    foreach my $i (0 .. 8) {
        foreach my $j (0 .. 8) {
            $entry{$i+1}{$j+1}->delete('0.0', 'end');
        }
    }
}

sub new {
    my ($class, $input) = @_;
    my @test;
    foreach my $i (1 .. 9) {
        foreach my $j (1 .. 9) {
            $test[$i-1][$j-1] = $input->{$i}{$j} || '';
        }
    }
    bless \@test, $class;
}

#not used
sub OutputPlace {
    my ($obj, $file) = @_;
    if ($file) {
        open my $out, '>', $file or die "can't write $file:$!";
        select $out;
    }
    else {
        select STDOUT;
    }
}

#not used
sub show {
    my $obj = shift;
    print '-' x 37, "\n";
    foreach my $i (0 .. $#$obj) {
        print '-' x 37, "\n" if $i and ! ($i % 3);
        print '|  ';
        foreach my $j (0 .. $#{$obj->[$i]}) {
            print $obj->[$i][$j] || ' ';
            if ($j == $#{$obj->[$i]}) {
                print $obj->[$i][$j] ? "  |\n" : "  |\n";
            }
            elsif ($j % 3 == 2) {
                print $obj->[$i][$j] ? "  |  " : "  |  ";
            }
            else {
                print "  ";
            }
        }
    }
    print '-' x 37, "\n";
}

sub FinishCount {
    my $obj = shift;
    my $count = 0;
    foreach my $i (0 .. $#$obj) {
        foreach my $j (0 .. $#{$obj->[$i]}) {
            $count++ if $obj->[$i][$j] and $obj->[$i][$j] =~ /\A\d\z/;
        }
    }
    return $count;
}

#not used
sub CheckSudoku {
    my ($obj, $method) = @_;
    $obj->$method if $method;
    $obj->show;
    print "the number of finish position = ", $obj->FinishCount, "\n\n";
}

sub exclude {
    my $obj = shift;
    my $judge = 0;
    until ($judge) {
        my $StartCount = $obj->FinishCount;
        foreach my $digit (1 .. @$obj) {
            $obj->ExcludeOneDigit($digit);
        }
        my $EndCount = $obj->FinishCount;
        $judge = 1 if $StartCount == $EndCount;
    }
}

sub ExcludeOneDigit {
    my ($obj, $digit) = @_;
    #exclude impossible block
    LOOP2:foreach my $i (0 .. $#$obj) {
        foreach my $j (0 .. $#{$obj->[$i]}) {
            next if $obj->[$i][$j] and $obj->[$i][$j] =~ /\A\d\z/;
            $obj->ExcludeOrFill($i, $j, $digit, 1);
        }
    }
    #fill sure block
    foreach my $i (0 .. $#$obj) {
        foreach my $j (0 .. $#{$obj->[$i]}) {
            next if $obj->[$i][$j];
            my $StartCount = $obj->FinishCount;
            $obj->ExcludeOrFill($i, $j, $digit, 0);
            my $EndCount = $obj->FinishCount;
            $obj->flush, goto LOOP2 if $EndCount != $StartCount;
        }
    }
    #delete char x
    $obj->flush;
}

sub flush {
    my $obj = shift;
    foreach my $i (0 .. $#$obj) {
        foreach my $j (0 .. $#{$obj->[$i]}) {
            $obj->[$i][$j] = '' if $obj->[$i][$j] eq 'x';
        }
    }
}

sub ExcludeOrFill {
    my ($obj, $i, $j, $digit, $exclude) = @_;
    $obj->[$i][$j] = do {
        #exclude or fill by row
        my $Rowjudge = 0;
        foreach my $col (0 .. $#{$obj->[$i]}) {
            $Rowjudge++ if ($exclude == 1 and $obj->[$i][$col] and $obj->[$i][$col] eq $digit) or (! $exclude and ! $obj->[$i][$col]);
            last if ($exclude == 1 and $Rowjudge) or (! $exclude and $Rowjudge == 2);
        }
        if    ($exclude == 1 and $Rowjudge  ) { 'x'    }
        elsif (! $exclude and $Rowjudge == 1) { $digit }
        else  {
            #exclude or fill by col
            my $Coljudge = 0;
            foreach my $row (0 .. $#$obj) {
                $Coljudge++ if ($exclude == 1 and $obj->[$row][$j] and $obj->[$row][$j] eq $digit) or (! $exclude and ! $obj->[$row][$j]);
                last if ($exclude == 1 and $Coljudge) or (! $exclude and $Coljudge == 2);
            }
            if    ($exclude == 1 and $Coljudge  ) { 'x'    }
            elsif (! $exclude and $Coljudge == 1) { $digit }
            else  {
                #exclude or fill by block
                my ($RowStart, $ColStart, $Blockjudge) = ($i - $i%3, $j - $j%3, 0);
                LOOP1:foreach my $row ($RowStart .. $RowStart+2) {
                    foreach my $col ($ColStart .. $ColStart+2) {
                        $Blockjudge++ if ($exclude == 1 and $obj->[$row][$col] and $obj->[$row][$col] eq $digit) or (! $exclude and ! $obj->[$row][$col]);
                        last LOOP1 if ($exclude == 1 and $Blockjudge) or (! $exclude and $Blockjudge == 2);
                    }
                }
                if    ($exclude == 1 and $Blockjudge  ) { 'x'            }
                elsif (! $exclude and $Blockjudge == 1) { $digit         }
                else                                    { $obj->[$i][$j] }
            }
        }
    };
}

sub remainder {
    my ($obj, $judge) = @_;
    my %possible;
    foreach my $i (0 .. $#$obj) {
        foreach my $j (0 .. $#{$obj->[$i]}) {
            next if $obj->[$i][$j];
            my %DigitCount;
            foreach my $col (0 .. $#{$obj->[$i]}) {
                $DigitCount{$obj->[$i][$col]}++ if $obj->[$i][$col] =~ /\A\d\z/;
            }
            foreach my $row (0 .. $#$obj) {
                $DigitCount{$obj->[$row][$j]}++ if $obj->[$row][$j] =~ /\A\d\z/;
            }
            my ($RowStart, $ColStart) = ($i - $i%3, $j - $j%3);
            foreach my $row ($RowStart .. $RowStart+2) {
                foreach my $col ($ColStart .. $ColStart+2) {
                    $DigitCount{$obj->[$row][$col]}++ if $obj->[$row][$col] =~ /\A\d\z/;                
                }
            }
            if (keys %DigitCount == $#$obj) {
                foreach my $digit (1 .. @$obj) {
                    if (! exists $DigitCount{$digit}) {
                        $obj->[$i][$j] = $digit;
                        last;
                    }
                }
            }
            if (keys %DigitCount < $#$obj and $judge) {
                foreach my $digit (1 .. @$obj) {
                    push @{$possible{"$i:$j"}}, $digit if ! exists $DigitCount{$digit};
                }
            }
        }
    }
    return \%possible;
}

sub copy {
    my $obj = shift;
    my @copy;
    foreach my $i (0 .. $#$obj) {
        push @copy, [ @{$obj->[$i]} ];
    }
    bless \@copy, __PACKAGE__;
}

sub guess {
    my $obj = shift;
    my $StartTime = join '.', Time::HiRes::gettimeofday;
    my $tmp = $obj->copy;
    my $possible = $obj->remainder(1);
    my @keys = sort { @{$possible->{$a}} <=> @{$possible->{$b}} or (split /:/, $a)[0] <=> (split /:/, $b)[0] or (split /:/, $a)[1] <=> (split /:/, $b)[1] } keys %$possible;
    my ($k, @guess) = (0);
    while ($k <= $#keys) {
        my $NowTime = join '.', Time::HiRes::gettimeofday;
        return 0 if $NowTime - $StartTime > $MaxTime;
        my ($i, $j) = split /:/, $keys[$k];
        my $digit = shift @{$possible->{$keys[$k]}};
        #die "The 'guess' method may be error !" if ! $digit;
        push @guess, [ $digit, $i, $j ];
        my $GuessBefore = $tmp->copy;
        $tmp->[$i][$j] = $digit;
        LOOP3:
        $tmp->exclude;
        my $StartCount = $tmp->FinishCount;
        $tmp->remainder;
        my $EndCount = $tmp->FinishCount;
        if ($EndCount > $StartCount) {
            goto LOOP3;
        }
        else {
            if ($tmp->FinishCount == @$tmp**2) {
                #print "Sudoku is successfully solved !\n";
                foreach my $i (0 .. $#$tmp) {
                    foreach my $j (0 .. $#{$tmp->[$i]}) {
                        $obj->[$i][$j] = $tmp->[$i][$j];
                    }
                }
                last;
            }
            else {
                $possible = $tmp->remainder(1);
                my $GuessOrRight = keys %$possible;
                #my $GuessOrRight = $tmp->OrRight;
                if ($GuessOrRight) {
                    $k++;
                }
                else {
                    my ($MayErrorDigit, $row, $col) = @{ pop @guess };
                    $tmp = $GuessBefore;
                    $possible = $tmp->remainder(1);
                    foreach my $s (0 .. $#{$possible->{"$row:$col"}}) {
                       splice(@{$possible->{"$row:$col"}}, $s, 1), last if $possible->{"$row:$col"}[$s] == $MayErrorDigit;
                    }
                    @keys = sort { @{$possible->{$a}} <=> @{$possible->{$b}} or (split /:/, $a)[0] <=> (split /:/, $b)[0] or (split /:/, $a)[1] <=> (split /:/, $b)[1] } keys %$possible;
                }
            }
        }
    }
    return 1;
}

sub OrRight {
    my $obj = shift;
    foreach my $i (0 .. $#$obj) {
        my @Digits = grep {/\A\d\z/} @{$obj->[$i]};
        my %RowDigitCount = map {$_, 1} @Digits;
        return 0 if keys %RowDigitCount != @Digits;
    }
    foreach my $j (0 .. $#{$obj->[0]}) {
        my @tmp;
        foreach my $i (0 .. $#$obj) {
            push @tmp, $obj->[$i][$j];
        }
        my @Digits = grep {/\A\d\z/} @tmp;
        my %ColDigitCount = map {$_, 1} @Digits;
        return 0 if keys %ColDigitCount != @Digits;
    }
    foreach my $RowBlockStart (0, 3, 6) {
        foreach my $ColBlockStart (0, 3, 6) {
            my %BlockDigitCount;
            my $DigitsCount = 0;
            foreach my $i ($RowBlockStart .. $RowBlockStart+2) {
                foreach my $j ($ColBlockStart .. $ColBlockStart+2) {
                    next if $obj->[$i][$j] !~ /\A\d\z/;
                    $BlockDigitCount{$obj->[$i][$j]}++;
                    $DigitsCount++;
                }
            }
            return 0 if keys %BlockDigitCount != $DigitsCount;
        }
    }
    return 1;
}
