/******************************************************************************
*
* MIT License
*
* Copyright (c) 2024 csBlueChip
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
******************************************************************************/

//-------------------------------------------------------------------------------------------------
// Include standard headers
//
#include  <stdio.h>      // standard IO : scanf, printf
#include  <stdint.h>     // standard integer types : UINT?_t
#include  <unistd.h>     // pidof()

//-------------------------------------------------------------------------------------------------
// debugger breakpoint
//
#define BPT  asm("int $3");

//-------------------------------------------------------------------------------------------------
// I ultimately need this code to work cross-platform.
// Let's guarantee htonl() is a MACRO (to keep the resultant code nice and clean)
// qv. https://stackoverflow.com/a/9283155
//
#define  LITTLE_ENDIAN     0x41424344UL 
#define  BIG_ENDIAN        0x44434241UL
#define  PDP_ENDIAN        0x42414443UL
#define  ENDIAN_ORDER      (0UL | ('A'<<24)|('B'<<16)|('C'<<8)|('D'))

#define  IS_BIG_ENDIAN     (ENDIAN_ORDER == BIG_ENDIAN)
#define  IS_LITTLE_ENDIAN  (ENDIAN_ORDER == LITTLE_ENDIAN)
#define  IS_PDP_ENDIAN     (ENDIAN_ORDER == PDP_ENDIAN)

#if    IS_BIG_ENDIAN
#	define  ENDIAN_STR  "Big"
#	define  HTONL(x)    (x)

#elif  IS_LITTLE_ENDIAN
#	define  ENDIAN_STR  "Little"
#	define  HTONL(x)    (\
		(((uint32_t)x          ) << 24    ) |\
		(((uint32_t)x &  0xFF00) << 8     ) |\
		(((uint32_t)x >> 8     ) &  0xFF00) |\
		(((uint32_t)x          ) >> 24    ) \
	)

#elif  IS_PDP_ENDIAN
#	define  ENDIAN_STR  "Peedeepee"
#	define  HTONL(x)    (\
		(((uint32_t)x &  0xFFFF) << 16    ) |\
		(((uint32_t)x >> 16    ) &  0xFFFF) |\
	)

#else
#	error  "What kind of hardware is this?!"
#endif

//-------------------------------------------------------------------------------------------------
// Game variables
//
uint32_t  answer  = HTONL(0x4E6F0000ul);  // Frankenstein's answer!
char      mode[2] = {0105,0};             // Game mode

//+================================================================================================
void  dog_groomer (uint32_t dcup)
{
	if (dcup == 721465653ul) {
		printf("* Friend #8, the assistant, helps make 'Her Sherrifness' look \"NFT Good\"\n");
		printf("  ...giving her the charisma to charm further Friends in to saying \"Yes\".\n");
		answer = HTONL(0x59657300ul);
	} else {
		printf("* Friend #7, the dog groomer, realises he is going need his assistant\n");
	}
	return;
}

//+================================================================================================
char   map[]  = {'*','\e','E','M','H'};
char*  pMap   = NULL;
char*  text[] = {
	"", "  ...Have you been looking for a way to escape?\n",
	"  ...The Sherrif deputises them, and orders another Shiny Badge.\n",
	"  ...The Sherrif pins the *second* Shiny Badge to the deputy.\n",
	"  ...Sees all the heads you've collected,\n"
	"     and proceeds to create a truly Cerberean Sherrif.\n",
	NULL, "tag", "9", "10, the courier", "11, Frankenstein"
};

void  cerberus (void)
{
	for (pMap = (map +sizeof(map) -1);  (pMap > map) && (*pMap != *mode);  pMap--);
		if ((pMap = (char*)(pMap -map))) {
			printf( "* Friend #%s, turns up and says: \"%s!\"\n%s", 
			        text[(size_t)pMap +sizeof(map)], (char*)&answer, 
			        (!(*(uint8_t*)&answer-0131)) ? text[(size_t)pMap] : text[0]
		);
	};
}

//+================================================================================================
void  vet (void)
{
	printf("* Friend #6 is a vet, and makes you a Happy Sherrif Dog\n");
	printf("  ...\"That bitch looks ruff; better get the dog_groomer().\n");
	printf("     He keeps moving, but there's a symbol on the map for his address.\"\n");
}

//-------------------------------------------------------------------------------------------------
// The structure of a good friend
//
typedef
	struct friend {
		char      mode[9];  // Game mode
		uint32_t  id;       // Friend ID
		char      name[5];  // All friends have 4 character names!
		uint32_t  job;      // Friend job code
	}
friend_t;

//+================================================================================================
void  input (const char* prompt,  char* result)
{
	printf(prompt);
	scanf("%[^\n]", result);
	(void)fgetc(stdin);
}

//+================================================================================================
void  get_mode (friend_t* pFriend)
{
	input("+ Mode? ([E]asy/[m]edium/[h]ard) : ", pFriend->mode);
	mode[0] = pFriend->mode[0] &~' ';

	printf("# Selected: ");
	switch (*mode+0) {
		case 72 : 
			printf("%s - Your BFF has gone in to hiding.", pFriend->mode);
			goto nl;

		case 77 :
			printf(pFriend->mode);
			nl: printf("\n");
			break;

		default:
			// You are not supposed to be able to read this section of the code,
			//   it is abusively-obfuscated so it doesn't 'spoiler' Mode=Medium
			// If you can work out what is does and explain how it achieves it,
			//   I will summon squirrel banditos for Her Sherrif'ness to chase
			volatile const size_t ll=(size_t)((uint8_t*)(pFriend)+(((uintptr_t)&((friend_t*)NULL)->id)&(uintptr_t)11534335)-('-'-'%'+'`'-'\\')),l1=(size_t)((((uint64_t)(pFriend)+017ul)>>' ')&(int)-1);
			printf("Easy mode ... Your BFF is currently at ");
			printf("0x%02x%04x%08x",l1>>0x10,l1&((1<<(1<<4))-1),ll);
			goto nl;
	}
}

//+================================================================================================
int  request (void)
{
	friend_t  friend = {
		.mode = "",
		.id   = HTONL(0xC5000000ul),
		.name = "Fred",
		.job  = HTONL(0xBC000000ul),
	};

	get_mode(&friend);

	printf("# Vet's address: %p, %sville\n", vet, ENDIAN_STR);

	input("+ Name? : ", friend.name);

	printf("# Friend {id=%X, job=%X}\n", friend.id, friend.job);

	if      (friend.job == HTONL(436257407ul))
		printf("* Friend #5 turns up with: A Shiny Sherrif Badge\n");

	else if (friend.job == HTONL(1073807360ul))
		printf("* Friend #4 turns up with: A Wagging Tail\n");

	else if (friend.job == HTONL(1096876032ul))
		printf("* Friend #3 turns up with: A Body\n");

	else if (friend.job == HTONL(0ul))
		printf("* Friend #2 turns up with: 4 Legs\n");

	else if (friend.job != HTONL(3154116608ul))
		printf("* Friend #1 turns up with: A Head\n");

	else
		printf("! Nobody turns up :(\n");

	return 0;
}

//++===============================================================================================
int  main (const int argc,  const char* const argv[],  const char* const envp[])
{
	printf("  ___ _  _ ___ ___ ___ _   ___ _ _ _\n"
	       "# | | |  | |__ |_/ |__ |   | | | | |  v1.2\n"
	       "# |_|  \\/  |__ | \\ |   |__ |_| |_|_|  csBlueChip, 2024\n\n");

	printf("# Friend Request ID: %d\n", getpid());

	request();

	printf("> clean exit\n");
	return 0;
}
